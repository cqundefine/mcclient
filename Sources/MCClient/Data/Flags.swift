enum TeleportFlags : Int32
{
    case RelativeX = 0x0001
    case RelativeY = 0x0002
    case RelativeZ = 0x0004
    case RelativeYaw = 0x0008
    case RelativePitch = 0x0010
    case RelativeVelocityX = 0x0020
    case RelativeVelocityY = 0x0040
    case RelativeVelocityZ = 0x0080
    case RotateVelocity = 0x0100
}

enum MovePlayerFlags : Int8
{
    case OnGround = 0x01
    case PushingAgainstWall = 0x02
}

extension Int32
{
    subscript(flags: TeleportFlags) -> Bool {
        return (self & flags.rawValue) > 0
    }
}

extension Int8
{
    subscript(flags: MovePlayerFlags) -> Bool {
        get {
            return (self & flags.rawValue) > 0
        }
        set {
            if newValue {
                self |= flags.rawValue
            } else {
                self &= ~flags.rawValue
            }
        }
    }
}
