import cglm

struct Vector3 : Hashable, CustomStringConvertible
{
    private(set) var data = glms_vec3_zero()
    
    var x: Float {
        get { return data.x }
        set { data.x = newValue }
    }    
    var y: Float {
        get { return data.y }
        set { data.y = newValue }
    }    
    var z: Float {
        get { return data.z }
        set { data.z = newValue }
    }

    var normalized: Vector3 {
        return Vector3(data: glms_normalize(data))
    }

    init()
    {
    }

    init(data: vec3s)
    {
        self.data = data
    }

    init(_ x: Float, _ y: Float, _ z: Float)
    {
        self.x = x
        self.y = y
        self.z = z
    }

    init(_ x: Int, _ y: Int, _ z: Int)
    {
        self.x = Float(x)
        self.y = Float(y)
        self.z = Float(z)
    }

    static func + (a: Vector3, b: Vector3) -> Vector3
    {
        return Vector3(a.x + b.x, a.y + b.y, a.z + b.z)
    }

    static func += (a: inout Vector3, b: Vector3)
    {
        a = Vector3(a.x + b.x, a.y + b.y, a.z + b.z)
    }

    static func - (a: Vector3, b: Vector3) -> Vector3
    {
        return Vector3(a.x - b.x, a.y - b.y, a.z - b.z)
    }

    static func -= (a: inout Vector3, b: Vector3)
    {
        a = Vector3(a.x - b.x, a.y - b.y, a.z - b.z)
    }

    static func * (a: Vector3, b: Float) -> Vector3
    {
        return Vector3(a.x * b, a.y * b, a.z * b)
    }

    static func cross(_ a: Vector3, _ b: Vector3) -> Vector3
    {
        return Vector3(data: glms_cross(a.data, b.data))
    }

    static func == (a: Vector3, b: Vector3) -> Bool
    {
        return a.x == b.x && a.y == b.y && a.z == b.z
    }

    func hash(into hasher: inout Hasher)
    {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }

    var description: String
    {
        return "Vector3(\(x), \(y), \(z))"
    }
}
