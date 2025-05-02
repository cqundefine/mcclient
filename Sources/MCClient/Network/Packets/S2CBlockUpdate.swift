import NIOCore

struct S2CBlockUpdate: S2CPacket
{
    static var packetKey = PacketKey(packetID: 0x08, connectionState: .Play)

    let position: Vector3
    let blockID: UInt32

    init(from buffer: inout ByteBuffer) throws
    {
        position = buffer.read()
        blockID = (buffer.read() as VarInt).value
    }
}
