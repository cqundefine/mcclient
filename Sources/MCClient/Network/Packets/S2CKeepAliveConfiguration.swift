import Foundation
import NIOCore

struct S2CKeepAliveConfiguration: Packet
{
    static let packetKey = PacketKey(packetID: 0x04,  connectionState: .Configuration)

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
