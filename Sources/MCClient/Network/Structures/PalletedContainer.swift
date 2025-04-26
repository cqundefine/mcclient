typealias PaletteStrategyFactory = (UInt8) throws -> PaletteStrategy

struct PalettedContainer<T>
{
    private(set) var values: [Int: T] = [:]

    init(reader: DataReader, size: Int, registry: Registry<T>?, paletteStrategyFactory: PaletteStrategyFactory) throws
    {
        let indexSize: UInt8 = try reader.read()
        let strategy = try paletteStrategyFactory(indexSize)

        let palette = try strategy(reader)

        if indexSize > 0 {
            let valuesPerLong = 64 / indexSize
            let longArraySize = ceilingDivision(size, Int(valuesPerLong))

            let data: [Int64] = try reader.read(arraySize: longArraySize)

            guard let _ = registry else {
                return
            }

            var index = 0
            for part in data {
                for i in 0..<valuesPerLong {
                    if index >= size {
                        break
                    }

                    let paletteIndex = Int(bitCut(part, position: Int(i * indexSize), count: Int(indexSize)))
                    values[index] = try registry!.get(palette.getIndexFor(UInt32(paletteIndex)))

                    index += 1
                }
            }

            assert(values.count == size)
        } else {
            guard let _ = registry else {
                return
            }

            for i in 0..<size {
                values[i] = try registry!.get(palette.getIndexFor(0))
            }
        }
    }
}
