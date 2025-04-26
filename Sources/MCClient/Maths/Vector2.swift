import Foundation

struct Vector2 : Hashable
{
    var x: Float
    var y: Float

    init(_ x: Float, _ y: Float)
    {
        self.x = x
        self.y = y
    }

    static func intDivide(_ a: Vector2, _ b: Vector2) -> Vector2
    {
        return Vector2(floorf(a.x / b.x), floorf(a.y / b.y))
    }
}
