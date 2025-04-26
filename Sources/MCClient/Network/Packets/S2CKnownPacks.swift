import NIOCore

struct S2CKnownPacks: S2CPacket
{
    static let packetKey = PacketKey(packetID: 0x0E, connectionState: .Configuration)

    init(from buffer: inout ByteBuffer) throws
    {
        // TODO
    }
}
