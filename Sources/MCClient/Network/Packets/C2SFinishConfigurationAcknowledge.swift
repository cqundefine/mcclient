import NIOCore

struct C2SFinishConfigurationAcknowledge: Packet
{
    static let packetKey = PacketKey(packetID: 0x03,  connectionState: .Configuration)

    init()
    {
        
    }

    init(from buffer: inout ByteBuffer) throws
    {
        fatalError()
    }

    func write(to buffer: inout ByteBuffer)
    {
    }
}
