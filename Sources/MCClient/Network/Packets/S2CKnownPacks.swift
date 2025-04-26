import NIOCore

struct S2CKnownPacks: Packet
{
    static let packetKey = PacketKey(packetID: 0x0E,  connectionState: .Configuration)

    init(from buffer: inout ByteBuffer) throws
    {
        // TODO
    }

    func write(to buffer: inout ByteBuffer)
    {
        fatalError()    
    }
}
