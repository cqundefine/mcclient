import GLFW3
import Foundation

class Camera
{
    var position: Vector3
    private(set) var front = Vector3()
    let up = Vector3(0.0, 1.0, 0.0)

    private let speed: Float = 0.5

    private var yaw: Float = -90.0
    private var pitch: Float = 0.0

    private var lastX: Double = 0
    private var lastY: Double = 0
    private var firstMouse = true

    var viewMatrix: Matrix4 {
        Matrix4.lookAt(eye: position, target: position + front, up: up)
    }

    init(position: Vector3)
    {
        self.position = position
    }

    func update()
    {
        if window.getKey(key: GLFW_KEY_W) {
            position += front * speed
        }
        if window.getKey(key: GLFW_KEY_S) {
            position -= front * speed
        }
        if window.getKey(key: GLFW_KEY_A) {
            position -= Vector3.cross(front, up).normalized * speed
        }
        if window.getKey(key: GLFW_KEY_D) {
            position += Vector3.cross(front, up).normalized * speed
        }
        if window.getKey(key: GLFW_KEY_SPACE) {
            position.y += speed
        }
        if window.getKey(key: GLFW_KEY_LEFT_SHIFT) {
            position.y -= speed
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
    }
}
