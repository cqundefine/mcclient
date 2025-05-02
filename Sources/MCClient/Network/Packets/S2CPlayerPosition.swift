import NIOCore

struct S2CPlayerPosition: S2CPacket
{
    static let packetKey = PacketKey(packetID: 0x41, connectionState: .Play)

    let teleportID: UInt32
    let x: Double
    let y: Double
    let z: Double
    let velocityX: Double
    let velocityY: Double
    let velocityZ: Double
    let yaw: Float
    let pitch: Float
    let flags: Int32

    init(from buffer: inout ByteBuffer) throws
    {
        teleportID = (buffer.read() as VarInt).value
        x = buffer.read()
        y = buffer.read()
        z = buffer.read()
        velocityX = buffer.read()
        velocityY = buffer.read()
        velocityZ = buffer.read()
        yaw = buffer.read()
        pitch = buffer.read()
        flags = buffer.read()
    }
}
