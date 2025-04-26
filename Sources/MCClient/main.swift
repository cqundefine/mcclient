import Foundation
import NIOCore
import GLFW3
import OpenGL

let window = try Window(width: 800, height: 600, title: "MCClient")

try loadRegistry()

let client = TCPClient(host: "localhost", port: 25565)
client.connect()

let region = try Data(contentsOf: URL(filePath: "chunk.mca"))
let anvilFile = AnvilFile(data: region)

var chunk: Chunk?

func processChunkData(packet: S2CChunkDataLight, client: TCPClient)
{
    if packet.chunkX == 0 && packet.chunkZ == 0 {
        DispatchQueue.main.async {
            chunk = try! Chunk(fromNetworkData: packet.chunkData, originX: Int(packet.chunkX), originZ: Int(packet.chunkZ))
        }
    }
}

func processBlockUpdate(packet: S2CBlockUpdate, client: TCPClient)
{
    if packet.position.x > 0 && packet.position.x < 16 && packet.position.z > 0 && packet.position.z < 16 {
        DispatchQueue.main.async {
            chunk!.setBlock(position: packet.position, block: try! blockStateRegistry!.get(packet.blockID))
        }
    }
}

let shader = try Shader(vertexShaderSource: PackageResources.basic_vert, fragmentShaderSource: PackageResources.basic_frag)
let projection = Matrix4.perspective(fov: 90, aspectRatio: Float(800) / 600, near: 0.1, far: 1000)
// let view = Matrix4.lookAt(eye: Vector3(-0.5, 7.5, -0.5), target: Vector3(5, 5, 5), up: Vector3(0, 1, 0))

// glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)

var cameraPosition = Vector3(-0.5, 7.5, -0.5)
var cameraFront = Vector3()

let cameraUp = Vector3(0.0, 1.0, 0.0)

var yaw: Float = -90.0
var pitch: Float = 0.0

var lastX: Double = 0
var lastY: Double = 0
var firstMouse = true

window.setMousePositionCallback { x, y in
    if firstMouse {
        lastX = x
        lastY = y
        firstMouse = false
    }

    let sensitivity = 0.1

    let xOffset = (x - lastX) * sensitivity
    let yOffset = (lastY - y) * sensitivity
    lastX = x
    lastY = y

    yaw += Float(xOffset)
    pitch += Float(yOffset)

    if pitch > 89.0 {
        pitch = 89.0
    }
    if pitch < -89.0 {
        pitch = -89.0
    }

    var direction = Vector3()
    direction.x = cos(toRadians(degrees: yaw)) * cos(toRadians(degrees: pitch))
    direction.y = sin(toRadians(degrees: pitch))
    direction.z = sin(toRadians(degrees: yaw)) * cos(toRadians(degrees: pitch))
    cameraFront = direction.normalized
}

let cameraSpeed: Float = 0.5

while !window.shouldClose() {
    // TODO: Does this return value matter?
    let _ = RunLoop.main.run(mode: .default, before: Date.distantPast)

    if window.getKey(key: GLFW_KEY_W) {
        cameraPosition += cameraFront * cameraSpeed
    }
    if window.getKey(key: GLFW_KEY_S) {
        cameraPosition -= cameraFront * cameraSpeed
    }
    if window.getKey(key: GLFW_KEY_A) {
        cameraPosition -= Vector3.cross(cameraFront, cameraUp).normalized * cameraSpeed
    }
    if window.getKey(key: GLFW_KEY_D) {
        cameraPosition += Vector3.cross(cameraFront, cameraUp).normalized * cameraSpeed
    }
    if window.getKey(key: GLFW_KEY_SPACE) {
        cameraPosition.y += cameraSpeed
    }
    if window.getKey(key: GLFW_KEY_LEFT_SHIFT) {
        cameraPosition.y -= cameraSpeed
    }

    let view = Matrix4.lookAt(eye: cameraPosition, target: cameraPosition + cameraFront, up: cameraUp)
    // view.translate(translation: cameraPosition)

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glClearColor(0.0, 0.0, 0.0, 1.0)

    shader.use()
    shader.setUniform(name: "projection", value: projection)
    shader.setUniform(name: "view", value: view)
    shader.setUniform(name: "model", value: Matrix4())
    chunk?.draw()

    window.update()
}
