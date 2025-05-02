import Foundation

class Chunk
{
    var sections: [Section] = []
    let originX: Int
    let originY: Int = -64
    let originZ: Int

    var mesh: Mesh?

    init(fromRegionData data: Data) throws
    {
        let parser = NBTParser(data: data)

        let chunk = try parser.parse().value
        originX = Int(try chunk.findCompoundChild(name: "xPos").int()) * 16
        originZ = Int(try chunk.findCompoundChild(name: "zPos").int()) * 16

        let sectionsList = try chunk.findCompoundChild(name: "sections").list()

        for sectionData in sectionsList {
            let section = try Section(fromRegionNBT: sectionData, parent: self)
            sections.append(section)
        }

        generateMesh()
    }

    init(fromNetworkData data: Data, originX: Int, originZ: Int) throws
    {
        self.originX = originX * 16
        self.originZ = originZ * 16

        let reader = DataReader(data: data)
        for y in 0..<(384/16) {
            let section = try Section(fromNetworkData: reader, originY: originY + (y * 16), parent: self)
            sections.append(section)
        }

        generateMesh()
    }

    func draw()
    {
        // FIXME: At this stage should we always have a mesh?
        mesh?.draw()
    }

    func isBlock(position: Vector3) -> Bool
    {
        let section = sectionForY(position.y)
        return section.blocks[position - Vector3(originX, section.originY, originZ)] != nil
    }

    func setBlock(position: Vector3, block: String)
    {
        let section = sectionForY(position.y)
        section.setBlock(position: position - Vector3(originX, section.originY, originZ), block: block)
        generateMesh()
    }

    private func generateMesh()
    {
        // TODO: Make mesh generation / update lazy
        let generator = MeshGenerator()
        for section in sections {
            section.appendMesh(generator: generator)
        }

        DispatchQueue.main.async {
            self.mesh = generator.finalize()
        }
    }

    private func sectionForY(_ y: Float) -> Section
    {
        return sections[(Int(y) - originY) / 16]
    }
}
