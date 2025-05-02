import Foundation
import NIOCore

struct S2CMoveEntityPosition: S2CPacket
{
    static var packetKey = PacketKey(packetID: 0x2E, connectionState: .Play)

    let entityID: UInt32
    let deltaX: Int16
    let deltaY: Int16
    let deltaZ: Int16
    let onGround: Bool

    init(from buffer: inout ByteBuffer) throws
    {
        entityID = (buffer.read() as VarInt).value
        deltaX = buffer.read()
        deltaY = buffer.read()
        deltaZ = buffer.read()
        onGround = buffer.read()
    }
}
