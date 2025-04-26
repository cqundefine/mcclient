import Foundation
import NIOCore

struct C2SLoginStartPacket: C2SPacket
{
    static let packetKey = PacketKey(packetID: 0x00,  connectionState: .Login)

    let name: String
    let uuid: UUID

    func write(to buffer: inout ByteBuffer)
    {
        buffer.write(string: name)
        buffer.write(uuid: uuid)
    }
}
