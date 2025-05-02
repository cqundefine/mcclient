class World
{
    private var chunks: [Vector2: Chunk] = [:]
    var entities: [UInt32: Vector3] = [:]

    func draw(shader: Shader)
    {
        shader.setUniform(name: "model", value: Matrix4())
        for (_, chunk) in chunks {
            chunk.draw()
        }

        for (_, location) in entities {
            shader.setUniform(name: "model", value: Matrix4.translation(location))
            entityMesh?.draw()
        }
    }

    func insertChunk(_ chunk: Chunk)
    {
        let origin = Vector2(chunk.originX / 16, chunk.originZ / 16)
        assert(chunks[origin] == nil)
        chunks[origin] = chunk
    }

    func isBlock(position: Vector3) -> Bool?
    {
        guard let chunk = chunks[Vector2.intDivide(position.xz, Vector2(16, 16))] else {
            return nil
        }
        return chunk.isBlock(position: position)
    }

    func setBlock(position: Vector3, block: String)
    {
        let chunk = chunks[Vector2.intDivide(position.xz, Vector2(16, 16))]!
        chunk.setBlock(position: position, block: block)
    }

    func getAABBs(location: Vector3, offset: Int = 3) -> [AABB]? // TODO: Get rid of offset?
    {
        var aabbs: [AABB] = []

        // TODO: We're probably getting to many AABBs
        for x in (Int(location.x) - offset)...(Int(location.x) + offset) {
            for y in (Int(location.y) - offset)...(Int(location.y) + offset) {
                for z in (Int(location.z) - offset)...(Int(location.z) + offset) {
                    if let value = isBlock(position: Vector3(x, y, z)) {
                        if value {
                            aabbs.append(AABB(min: Vector3(x, y, z), max: Vector3(x + 1, y + 1, z + 1)))
                        }
                    } else {
                        return nil
                    }
                }
            }
        }

        return aabbs
    }
}
