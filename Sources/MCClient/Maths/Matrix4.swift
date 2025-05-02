import cglm

struct Matrix4
{
    public private(set) var data = glms_mat4_zero()

    init()
    {
        data = glms_mat4_identity()
    }

    init(data: mat4s)
    {
        self.data = data
    }

    mutating func translate(_ translation: Vector3)
    {
        data = glms_translate(data, translation.data)
    }

    static func translation(_ translation: Vector3) -> Matrix4
    {
        var matrix = Matrix4()
        matrix.translate(translation)
        return matrix
    }

    static func perspective(fov: Float, aspectRatio: Float, near: Float, far: Float) -> Matrix4
    {
        return Matrix4(data: glms_perspective(fov, aspectRatio, near, far))
    }

    static func lookAt(eye: Vector3, target: Vector3, up: Vector3) -> Matrix4
    {
        return Matrix4(data: glms_lookat(eye.data, target.data, up.data))
    }
}
