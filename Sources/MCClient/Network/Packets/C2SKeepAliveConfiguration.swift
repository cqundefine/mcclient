import Foundation
import NIOCore

struct C2SKeepAliveConfiguration: Packet
{
    static let packetKey = PacketKey(packetID: 0x04,  connectionState: .Configuration)

    let keepAliveID: Int64

    init(keepAliveID: Int64)
    {
        self.keepAliveID = keepAliveID
    }

    init(from buffer: inout ByteBuffer) throws
    {
        fatalError()
    }

    func write(to buffer: inout ByteBuffer)
    {
        buffer.write(integer: keepAliveID)
    }
}
