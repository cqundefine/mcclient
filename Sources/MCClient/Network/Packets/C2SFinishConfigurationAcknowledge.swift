import NIOCore

struct C2SFinishConfigurationAcknowledge: C2SPacket
{
    static let packetKey = PacketKey(packetID: 0x03, connectionState: .Configuration)

    func write(to buffer: inout ByteBuffer)
    {
    }
}
