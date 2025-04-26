import NIOCore

struct S2CFinishConfiguration: Packet
{
    static let packetKey = PacketKey(packetID: 0x03,  connectionState: .Configuration)

    init(from buffer: inout ByteBuffer) throws
    {

    }

    func write(to buffer: inout ByteBuffer)
    {
        fatalError()    
    }
}
