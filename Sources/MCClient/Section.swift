import Foundation

enum SectionError : Error
{
    case TooMuchBlockData
    case InvalidIndexSize(indexSize: UInt8, for: String)
}

class Section
{
    var blocks: [Vector3: Vector3] = [:]
    let originY: Int

    weak var parent: Chunk?

    init(fromRegionNBT section: NBTValue, parent: Chunk) throws
    {
        self.parent = parent

        originY = Int(try section.findCompoundChild(name: "Y").byte()) * 16

        let blockStates = try section.findCompoundChild(name: "block_states")
        let palette = try blockStates.findCompoundChild(name: "palette").list()

        var decodedPalette: [String] = []

        for block in palette {
            let name = try block.findCompoundChild(name: "Name").string()
            decodedPalette.append(name)
        }

        let indexSize = Int(ceil(log2f(Float(decodedPalette.count))))

        if indexSize == 0 {
            for x in 0..<16 {
                for y in 0..<16 {
                    for z in 0..<16 {
                        if let color = getBlockColor(block: decodedPalette[0]) {
                            blocks[Vector3(x, y, z)] = color
                        }
                    }
                }
            }
            // throw SectionError.UnsupportedIndexSize
        } else {
            var position = Vector3(0, 0, 0)
            let data = try blockStates.findCompoundChild(name: "data").longArray()
            for part in data {
                for i in 0..<(64 / indexSize) {
                    // FIXME: This adds extra blocks if arraySize is not divisible by indexSize
                    let index = Int(bitCut(part, position: i * indexSize, count: indexSize))

                    if let color = getBlockColor(block: decodedPalette[index]) {
                        blocks[position] = color
                    }

                    position.x += 1
                    if position.x == 16 {
                        position.x = 0

                        position.z += 1
                        if position.z == 16 {
                            position.z = 0

                            position.y += 1
                            if position.y == 16 {
                                if position.x == 0 && position.z == 0 {
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    init(fromNetworkData reader: DataReader, originY: Int, parent: Chunk) throws
    {
        self.parent = parent
        self.originY = originY

        let _: Int16 = try reader.read()

        let sectionSize = 16 * 16 * 16
        let states = try PalettedContainer<String>(reader: reader, size: sectionSize, registry: blockStateRegistry!, paletteStrategyFactory: blockStatePaletteStrategyFactory(indexSize:))

        var position = Vector3(0, 0, 0)
        for i in 0..<sectionSize {
            let block = states.values[i]!
            if let color = getBlockColor(block: block) {
                blocks[position] = color
            }

            position.x += 1
            if position.x == 16 {
                position.x = 0

                position.z += 1
                if position.z == 16 {
                    position.z = 0

                    position.y += 1
                    if position.y == 16 {
                        if position.x == 0 && position.z == 0 {
                            break
                        }
                    }
                }
            }
        }

        let _ = try PalettedContainer<String>(reader: reader, size: 4 * 4 * 4, registry: nil, paletteStrategyFactory: biomePaletteStrategyFactory(indexSize:))
    }

    func appendMesh(generator: MeshGenerator)
    {
        for (location, color) in blocks {
            let actualLocation = location + Vector3(parent!.originX, originY, parent!.originZ)

            if blocks[location - Vector3(0, 1, 0)] == nil {
                generator.addSquare(a: actualLocation, color: color, plane: .XZ) // Bottom
            }

            if blocks[location + Vector3(0, 1, 0)] == nil {
                generator.addSquare(a: actualLocation + Vector3(0, generator.cellSize, 0), color: color, plane: .XZ) // Top
            }

            if blocks[location - Vector3(1, 0, 0)] == nil {
                generator.addSquare(a: actualLocation, color: color, plane: .YZ) // Left
            }

            if blocks[location + Vector3(1, 0, 0)] == nil {
                generator.addSquare(a: actualLocation + Vector3(generator.cellSize, 0, 0), color: color, plane: .YZ) // Right
            }

            if blocks[location - Vector3(0, 0, 1)] == nil {
                generator.addSquare(a: actualLocation, color: color, plane: .XY) // Back
            }

            if blocks[location + Vector3(0, 0, 1)] == nil {
                generator.addSquare(a: actualLocation + Vector3(0, 0, generator.cellSize), color: color, plane: .XY) // Front
            }
        }
    }

    func setBlock(position: Vector3, block: String)
    {
        blocks.removeValue(forKey: position)

        if let color = getBlockColor(block: block) {
            blocks[position] = color
        }
    }

    private func blockStatePaletteStrategyFactory(indexSize: UInt8) throws -> PaletteStrategy
    {
        switch indexSize {
            case 0:
                return singleValuedPaletteStrategy(reader:)
            case 4...8:
                return indirectPaletteStrategy(reader:)
            case 15:
                return directPaletteStrategy(reader:)
            default:
                throw SectionError.InvalidIndexSize(indexSize: indexSize, for: "BlockState")
        }
    }

    private func biomePaletteStrategyFactory(indexSize: UInt8) throws -> PaletteStrategy
    {
        switch indexSize {
            case 0:
                return singleValuedPaletteStrategy(reader:)
            case 1...3:
                return indirectPaletteStrategy(reader:)
            case 6:
                return directPaletteStrategy(reader:)
            default:
                throw SectionError.InvalidIndexSize(indexSize: indexSize, for: "Biome")
        }
    }

    private func getBlockColor(block: String) -> Vector3?
    {
        if block == "minecraft:air" || block == "minecraft:leaf_litter" || block == "minecraft:short_grass" {
            return nil
        }

        return switch block {
            case "minecraft:grass_block":
                Vector3(0.0, 0.8, 0.0)
            case "minecraft:dirt":
                Vector3(0.275, 0.145, 0.0)
            case "minecraft:stone":
                Vector3(0.412, 0.412, 0.412)
            case "minecraft:deepslate":
                Vector3(0.212, 0.212, 0.212)
            case "minecraft:oak_log":
                Vector3(0.55, 0.357, 0.0)
            case let s where s.contains("leaves"):
                Vector3(0.118, 0.5, 0.067)
            case "minecraft:coal_ore":
                Vector3(0.0, 0.0, 0.0)
            case "minecraft:lava":
                Vector3(1.0, 0.333, 0.0)
            case "minecraft:red_wool":
                Vector3(0.753, 0.0, 0.0)
            default:
                Vector3(1.0, 1.0, 1.0)
        }
    }
}
