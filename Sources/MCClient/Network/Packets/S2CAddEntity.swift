import Foundation
import NIOCore

struct S2CAddEntity: S2CPacket
{
    static var packetKey = PacketKey(packetID: 0x01, connectionState: .Play)

    let entityID: UInt32
    let entityUUID: UUID
    let type: UInt32
    let x: Double
    let y: Double
    let z: Double
    let pitch: UInt8
    let yaw: UInt8
    let headYaw: UInt8
    let data: UInt32
    let velocityX: Int16
    let velocityY: Int16
    let velocityZ: Int16

    init(from buffer: inout ByteBuffer) throws
    {
        entityID = (buffer.read() as VarInt).value
        entityUUID = buffer.read()
        type = (buffer.read() as VarInt).value
        x = buffer.read()
        y = buffer.read()
        z = buffer.read()
        pitch = buffer.read()
        yaw = buffer.read()
        headYaw = buffer.read()
        data = (buffer.read() as VarInt).value
        velocityX = buffer.read()
        velocityY = buffer.read()
        velocityZ = buffer.read()
    }
}
