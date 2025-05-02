import NIOCore

struct S2CLogin: S2CPacket
{
    static let packetKey = PacketKey(packetID: 0x2B, connectionState: .Play)

    let entityID: Int32

    init(from buffer: inout ByteBuffer) throws
    {
        entityID = buffer.read()
        // TODO
    }
}
