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

    func addSquare(a: Vector3, color: Vector3, plane: Plane)
    {
        let begin = UInt32(vertices.count / Vertex.elementCount)

        switch plane {
            case .XZ:
                vertices.append(contentsOf: [a.x,            a.y, a.z + cellSize, color.x, color.y, color.z])
                vertices.append(contentsOf: [a.x,            a.y, a.z           , color.x, color.y, color.z])
                vertices.append(contentsOf: [a.x + cellSize, a.y, a.z           , color.x, color.y, color.z])
                vertices.append(contentsOf: [a.x + cellSize, a.y, a.z + cellSize, color.x, color.y, color.z])
            
            case .XY:
                vertices.append(contentsOf: [a.x,            a.y + cellSize, a.z, color.x, color.y, color.z])
                vertices.append(contentsOf: [a.x,            a.y,            a.z, color.x, color.y, color.z])
                vertices.append(contentsOf: [a.x + cellSize, a.y,            a.z, color.x, color.y, color.z])
                vertices.append(contentsOf: [a.x + cellSize, a.y + cellSize, a.z, color.x, color.y, color.z])

            case .YZ:
                vertices.append(contentsOf: [a.x, a.y + cellSize, a.z           , color.x, color.y, color.z])
                vertices.append(contentsOf: [a.x, a.y,            a.z           , color.x, color.y, color.z])
                vertices.append(contentsOf: [a.x, a.y,            a.z + cellSize, color.x, color.y, color.z])
                vertices.append(contentsOf: [a.x, a.y + cellSize, a.z + cellSize, color.x, color.y, color.z])
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
