import OpenGL

struct Vertex
{
    let position: Vector3
    let color: Vector3

    static var elementCount: Int {
        return 6
    }
}

class Mesh
{
    var vao: GLuint = 0
    var vbo: GLuint = 0
    var ibo: GLuint = 0

    let count: Int32

    init(vertices: [Float], indices: [UInt32])
    {
        count = Int32(indices.count)
        
        glCreateVertexArrays(1, &vao)

        glCreateBuffers(1, &vbo)
        glNamedBufferData(buffer: vbo, size: MemoryLayout<GLfloat>.stride * vertices.count, data: vertices, usage: GL_STATIC_DRAW)

        glCreateBuffers(1, &ibo)
        glNamedBufferData(buffer: ibo, size: MemoryLayout<GLuint>.stride * indices.count, data: indices, usage: GL_STATIC_DRAW)

        glVertexArrayVertexBuffer(vaobj: vao, bindingindex: 0, buffer: vbo, offset: 0, stride: Int32(MemoryLayout<Vertex>.stride))
        glVertexArrayElementBuffer(vaobj: vao, buffer: ibo)

        glEnableVertexArrayAttrib(vao, 0)
        glEnableVertexArrayAttrib(vao, 1)

        glVertexArrayAttribFormat(vaobj: vao, attribindex: 0, size: 3, type: GL_FLOAT, normalized: false, relativeoffset: UInt32(MemoryLayout.offset(of: \Vertex.position)!))
        glVertexArrayAttribFormat(vaobj: vao, attribindex: 1, size: 3, type: GL_FLOAT, normalized: false, relativeoffset: UInt32(MemoryLayout.offset(of: \Vertex.color)!))

        glVertexArrayAttribBinding(vaobj: vao, attribindex: 0, bindingindex: 0)
        glVertexArrayAttribBinding(vaobj: vao, attribindex: 1, bindingindex: 0)
    }

    deinit
    {
        glDeleteBuffers(1, &ibo)
        glDeleteBuffers(1, &vbo)
        glDeleteVertexArrays(1, &vao)
    }

    func draw()
    {
        glBindVertexArray(vao)
        glDrawElements(mode: GL_TRIANGLES, count: count, type: GL_UNSIGNED_INT, indices: nil)
    }
}
