import Foundation
import NIOCore

struct C2SKeepAliveConfiguration: C2SPacket
{
    static let packetKey = PacketKey(packetID: 0x04, connectionState: .Configuration)

    let keepAliveID: Int64

    func write(to buffer: inout ByteBuffer)
    {
        buffer.write(integer: keepAliveID)
    }
}
