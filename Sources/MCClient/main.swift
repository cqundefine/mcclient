import Foundation
import OpenGL

let window = try Window(width: 800, height: 600, title: "MCClient")

try loadRegistry()

let client = TCPClient(host: "localhost", port: 25565)
client.connect()

var chunks: [Vector2: Chunk] = [:]

func processChunkData(packet: S2CChunkDataLight, client: TCPClient) throws
{
    let newChunk = try Chunk(fromNetworkData: packet.chunkData, originX: Int(packet.chunkX), originZ: Int(packet.chunkZ))
    chunks[Vector2(Float(packet.chunkX), Float(packet.chunkZ))] = newChunk
}

func processBlockUpdate(packet: S2CBlockUpdate, client: TCPClient) throws
{
    let chunk = chunks[Vector2.intDivide(packet.position.xz, Vector2(16, 16))]!
    chunk.setBlock(position: packet.position, block: try blockStateRegistry!.get(packet.blockID))
 }

let shader = try Shader(vertexShaderSource: PackageResources.basic_vert, fragmentShaderSource: PackageResources.basic_frag)
let projection = Matrix4.perspective(fov: 90, aspectRatio: Float(800) / 600, near: 0.1, far: 1000)

// glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)

let camera = Camera(position: Vector3(0, 100, 0))

window.setMousePositionCallback { x, y in
    camera.onMousePositionChange(x: x, y: y)
}

while !window.shouldClose() {
    assert(RunLoop.main.run(mode: .default, before: Date.distantPast))

    camera.update()

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glClearColor(0.0, 0.0, 0.0, 1.0)

    shader.use()
    shader.setUniform(name: "projection", value: projection)
    shader.setUniform(name: "view", value: camera.viewMatrix)
    shader.setUniform(name: "model", value: Matrix4())

    for (_, chunk) in chunks {
        chunk.draw()
    }

    window.update()
}
