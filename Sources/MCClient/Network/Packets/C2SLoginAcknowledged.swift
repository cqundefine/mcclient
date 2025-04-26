import NIOCore

struct C2SLoginAcknowledged: C2SPacket
{
    static let packetKey = PacketKey(packetID: 0x03,  connectionState: .Login)

    func write(to buffer: inout ByteBuffer)
    {
        
    }
}
