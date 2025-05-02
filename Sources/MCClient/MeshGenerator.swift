import OpenGL

class MeshGenerator
{
    let cellSize: Float = 1.0
    let atlasXUnit: Float = 1.0 / 4
    let atlasYUnit: Float = 1.0 / 2

    private var vertices: [GLfloat] = []
    private var indices: [GLuint] = []

    enum Plane
    {
        case XZ
        case XY
        case YZ
    }

    func addSquare(position: Vector3, color: Vector3, plane: Plane)
    {
        let begin = UInt32(vertices.count / Vertex.elementCount)

        switch plane {
            case .XZ:
                vertices.append(contentsOf: [position.x,            position.y, position.z + cellSize, color.x, color.y, color.z])
                vertices.append(contentsOf: [position.x,            position.y, position.z           , color.x, color.y, color.z])
                vertices.append(contentsOf: [position.x + cellSize, position.y, position.z           , color.x, color.y, color.z])
                vertices.append(contentsOf: [position.x + cellSize, position.y, position.z + cellSize, color.x, color.y, color.z])
            
            case .XY:
                vertices.append(contentsOf: [position.x,            position.y + cellSize, position.z, color.x, color.y, color.z])
                vertices.append(contentsOf: [position.x,            position.y,            position.z, color.x, color.y, color.z])
                vertices.append(contentsOf: [position.x + cellSize, position.y,            position.z, color.x, color.y, color.z])
                vertices.append(contentsOf: [position.x + cellSize, position.y + cellSize, position.z, color.x, color.y, color.z])

            case .YZ:
                vertices.append(contentsOf: [position.x, position.y + cellSize, position.z           , color.x, color.y, color.z])
                vertices.append(contentsOf: [position.x, position.y,            position.z           , color.x, color.y, color.z])
                vertices.append(contentsOf: [position.x, position.y,            position.z + cellSize, color.x, color.y, color.z])
                vertices.append(contentsOf: [position.x, position.y + cellSize, position.z + cellSize, color.x, color.y, color.z])
        }

        indices.append(contentsOf: [begin + 0, begin + 1, begin + 3])
        indices.append(contentsOf: [begin + 3, begin + 1, begin + 2])
    }

    @MainActor
    func finalize() -> Mesh
    {
        return Mesh(vertices: vertices, indices: indices)
    }
}
