import NIOCore

struct C2SKnownPacks: Packet
{
    static let packetKey = PacketKey(packetID: 0x07,  connectionState: .Configuration)

    init()
    {
        
    }

    init(from buffer: inout ByteBuffer) throws
    {
        fatalError()
    }

    func write(to buffer: inout ByteBuffer)
    {
        // TODO: Use prefixedArray
        buffer.write(varInt: 0)
    }
}
