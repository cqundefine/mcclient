import NIOCore

struct C2SKeepAlivePlay: C2SPacket
{
    static let packetKey = PacketKey(packetID: 0x1A, connectionState: .Play)

    let keepAliveID: Int64

    func write(to buffer: inout ByteBuffer)
    {
        buffer.write(integer: keepAliveID)
    }
}
