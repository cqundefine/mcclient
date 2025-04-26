import NIOCore

struct C2SKnownPacks: C2SPacket
{
    static let packetKey = PacketKey(packetID: 0x07, connectionState: .Configuration)

    func write(to buffer: inout ByteBuffer)
    {
        // TODO: Use prefixedArray
        buffer.write(varInt: 0)
    }
}
