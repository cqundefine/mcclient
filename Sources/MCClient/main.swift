import Foundation
import OpenGL
import NIOCore
import GLFW3

guard Endianness.host == .little else {
    fatalError("Big endian is not supported")
}

let window = try Window(width: 800, height: 600, title: "MCClient")

try loadRegistry()

let client = TCPClient(host: "localhost", port: 25565)
// let client = TCPClient(host: "undefine.pl", port: 13337)
client.connect()

let entityMeshVertices: [GLfloat] = [
    0.0, 2.0, 1.0, 1.0, 1.0, 1.0,
    0.0, 0.0, 1.0, 1.0, 1.0, 1.0,
    1.0, 0.0, 1.0, 1.0, 1.0, 1.0,
    1.0, 2.0, 1.0, 1.0, 1.0, 1.0,
    0.0, 2.0, 0.0, 1.0, 1.0, 1.0,
    1.0, 2.0, 0.0, 1.0, 1.0, 1.0,
    0.0, 0.0, 0.0, 1.0, 1.0, 1.0,
    1.0, 0.0, 0.0, 1.0, 1.0, 1.0,
]

let entityMeshIndices: [GLuint] = [
    0, 1, 3, 3, 1, 2,
    4, 0, 3, 5, 4, 3,
    3, 2, 7, 5, 3, 7,
    6, 1, 0, 6, 0, 4,
    2, 1, 6, 2, 6, 7,
    7, 6, 4, 7, 4, 5,
]

var entityMesh: Mesh?
DispatchQueue.main.async {
    entityMesh = Mesh(vertices: entityMeshVertices, indices: entityMeshIndices)
}

var world: World?

func processChunkData(packet: S2CChunkDataLight, client: TCPClient) throws
{
    let newChunk = try Chunk(fromNetworkData: packet.chunkData, originX: Int(packet.chunkX), originZ: Int(packet.chunkZ))
    world!.insertChunk(newChunk)
}

func processBlockUpdate(packet: S2CBlockUpdate, client: TCPClient) throws
{
    world!.setBlock(position: packet.position, block: try blockStateRegistry!.get(packet.blockID))
}

func processAddEntity(packet: S2CAddEntity, client: TCPClient) throws
{
    guard let world else {
        fatalError()
    }
    if try entityTypeRegistry!.get(packet.type) == "minecraft:player" {
        world.entities[packet.entityID] = Vector3(Float(packet.x), Float(packet.y), Float(packet.z))
    }
}

func processMoveEntity(packet: S2CMoveEntityPosition, client: TCPClient)
{
    guard let world else {
        fatalError()
    }
    if var entity = world.entities[packet.entityID] {
        entity.x += Float(packet.deltaX) / 4096
        entity.y += Float(packet.deltaY) / 4096
        entity.z += Float(packet.deltaZ) / 4096
        world.entities[packet.entityID] = entity
    }
}

func processLogin(packet: S2CLogin, client: TCPClient)
{
    print(packet)
    world = World()
    player = Player(world: world!)
}

func processPlayerPosition(packet: S2CPlayerPosition, client: TCPClient) throws
{
    guard !packet.flags[.RotateVelocity] else {
        print("Unsupported player position flags: \(packet.flags)")
        return
    }

    guard let player else {
        fatalError()
    }

    player.position.x = if packet.flags[.RelativeX] { player.position.x + Float(packet.x) } else { Float(packet.x) }
    player.position.y = if packet.flags[.RelativeY] { player.position.y + Float(packet.y) } else { Float(packet.y) }
    player.position.z = if packet.flags[.RelativeZ] { player.position.z + Float(packet.z) } else { Float(packet.z) }

    player.velocity.x = if packet.flags[.RelativeVelocityX] { player.velocity.x + Float(packet.velocityX) } else { Float(packet.velocityX) }
    player.velocity.y = if packet.flags[.RelativeVelocityY] { player.velocity.y + Float(packet.velocityY) } else { Float(packet.velocityY) }
    player.velocity.z = if packet.flags[.RelativeVelocityZ] { player.velocity.z + Float(packet.velocityZ) } else { Float(packet.velocityZ) }

    let _ = try client.send(packet: C2SAcceptTeleportation(teleportID: packet.teleportID)).assertSuccess()
}

let shader = try Shader(vertexShaderSource: PackageResources.basic_vert, fragmentShaderSource: PackageResources.basic_frag)
let projection = Matrix4.perspective(fov: 90, aspectRatio: Float(800) / 600, near: 0.1, far: 1000)

// glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)

var player: Player?

var lastTime = glfwGetTime()

while !window.shouldClose() {
    let deltaTime = Float(glfwGetTime() - lastTime)
    lastTime = glfwGetTime()
    window.title = "MCClient / FPS: \(Int(1 / deltaTime))"

    assert(RunLoop.main.run(mode: .default, before: Date.distantPast))

    try player?.update(deltaTime: deltaTime)

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glClearColor(0.0, 0.0, 0.0, 1.0)

    if let player {
        guard let world else {
            fatalError()
        }

        shader.use()
        shader.setUniform(name: "projection", value: projection)
        shader.setUniform(name: "view", value: player.camera!.viewMatrix)

        world.draw(shader: shader)
    }

    window.update()
}
