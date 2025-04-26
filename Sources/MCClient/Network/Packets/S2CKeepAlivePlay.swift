import Foundation
import NIOCore

struct S2CKeepAlivePlay: Packet
{
    static let packetKey = PacketKey(packetID: 0x1A,  connectionState: .Play)

    let keepAliveID: Int64

    init(from buffer: inout ByteBuffer) throws
    {
        keepAliveID = buffer.read()
    }

    func write(to buffer: inout ByteBuffer)
    {
        fatalError()   
    }
}
