import NIOCore

struct S2CFinishConfiguration: S2CPacket
{
    static let packetKey = PacketKey(packetID: 0x03, connectionState: .Configuration)

    init(from buffer: inout ByteBuffer) throws
    {
    }
}
