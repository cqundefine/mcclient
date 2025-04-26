import Foundation
import NIOCore

struct S2CLoginSuccess: S2CPacket
{
    static let packetKey = PacketKey(packetID: 0x02, connectionState: .Login)

    let uuid: UUID
    let username: String

    init(from buffer: inout ByteBuffer) throws
    {
        uuid = buffer.read()
        username = buffer.read()
    }
}
