import Foundation
import NIOCore

struct C2SLoginStartPacket: Packet
{
    static let packetKey = PacketKey(packetID: 0x00,  connectionState: .Login)

    enum NextState: VarInt
    {
        case Status = 1
        case Login = 2
        case Transfer = 3
    }

    let name: String
    let uuid: UUID

    init(name: String, uuid: UUID)
    {
        self.name = name
        self.uuid = uuid
    }

    init(from buffer: inout ByteBuffer) throws
    {
        fatalError()
    }

    func write(to buffer: inout ByteBuffer)
    {
        buffer.write(string: name)
        buffer.write(uuid: uuid)
    }
}
