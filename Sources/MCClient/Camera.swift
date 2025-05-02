import GLFW3
import Foundation

class Camera
{
    private(set) var front = Vector3()
    private(set) var forward = Vector3()
    let up = Vector3(0.0, 1.0, 0.0)

    weak var player: Player?

    private var yaw: Float = -90.0
    private var pitch: Float = 0.0

    private var lastX: Double = 0
    private var lastY: Double = 0
    private var firstMouse = true

    var viewMatrix: Matrix4 {
        Matrix4.lookAt(eye: player!.position + Vector3(0, player!.eyeHeight, 0), target: player!.position + Vector3(0, player!.eyeHeight, 0) + front, up: up)
    }

    init(player: Player)
    {
        self.player = player

        window.addMousePositionCallback { x, y in
            self.onMousePositionChange(x: x, y: y)
        }
    }

    func onMousePositionChange(x: Double, y: Double)
    {
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
        front = direction.normalized

        direction = Vector3()
        direction.x = cos(toRadians(degrees: yaw))
        direction.z = sin(toRadians(degrees: yaw))
        forward = direction.normalized
    }
}
