import NIOCore

struct C2SLoginAcknowledged: Packet
{
    static let packetKey = PacketKey(packetID: 0x03,  connectionState: .Login)

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
