import GLFW3

class Player
{
    var camera: Camera?

    var position = Vector3()
    var velocity = Vector3()

    var onGround = false

    let eyeHeight: Float = 1.62
    let height: Float = 1.8
    let size: Float = 0.6

    let gravity: Float = 2
    let speed: Float = 7

    private let world: World

    var aabb: AABB {
        return AABB(min: position - Vector3(size / 2, 0, size / 2), max: position + Vector3(size / 2, height, size / 2))
    }

    var intersectsWithWorld: Bool {
        let aabbs = world.getAABBs(location: position)
        if let aabbs = aabbs {
            return aabb.intersects(others: aabbs)
        } else {
            // Don't allow movement in unloaded chunks
            return true
        }
    }

    init(world: World)
    {
        self.world = world
        camera = Camera(player: self)
    }

    func update(deltaTime: Float) throws
    {
        if velocity.y > -(gravity * 3) {
            velocity.y -= gravity
        }

        var frameVelocity = Vector3()

        if window.getKey(key: GLFW_KEY_W) {
            frameVelocity += camera!.forward * speed
        }
        if window.getKey(key: GLFW_KEY_S) {
            frameVelocity -= camera!.forward * speed
        }
        if window.getKey(key: GLFW_KEY_A) {
            frameVelocity -= Vector3.cross(camera!.forward, camera!.up).normalized * speed
        }
        if window.getKey(key: GLFW_KEY_D) {
            frameVelocity += Vector3.cross(camera!.forward, camera!.up).normalized * speed
        }
        if window.getKey(key: GLFW_KEY_SPACE) && onGround {
            velocity.y = 15
        }

        frameVelocity += velocity
        frameVelocity *= deltaTime

        position.x += frameVelocity.x
        if intersectsWithWorld {
            position.x -= frameVelocity.x
            velocity.x = 0
        }

        position.y += frameVelocity.y
        if intersectsWithWorld {
            if frameVelocity.y < 0 {
                onGround = true
            } else {
                onGround = false
            }
            position.y -= frameVelocity.y
            velocity.y = 0
        } else {
            onGround = false
        }

        position.z += frameVelocity.z
        if intersectsWithWorld {
            position.z -= frameVelocity.z
            velocity.z = 0
        }

        var flags: Int8 = 0
        flags[.OnGround] = onGround

        let _ = try client.send(packet: C2SMovePlayerPosition(x: Double(position.x), y: Double(position.y), z: Double(position.z), flags: flags)).assertSuccess()
    }
}
