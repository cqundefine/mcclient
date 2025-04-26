import NIOCore

let DEFAULT_PROTOCOL_VERSION: UInt32 = 770

struct C2SHandshakePacket: Packet
{
    static let packetKey = PacketKey(packetID: 0x00,  connectionState: .Login)

    enum NextState: VarInt
    {
        case Status = 1
        case Login = 2
        case Transfer = 3
    }

    let protocolVersion: UInt32
    let serverAddress: String
    let serverPort: UInt16
    let nextState: NextState

    init(protocolVersion: UInt32 = DEFAULT_PROTOCOL_VERSION, serverAddress: String, serverPort: UInt16, nextState: NextState = NextState.Login)
    {
        self.protocolVersion = protocolVersion
        self.serverAddress = serverAddress
        self.serverPort = serverPort
        self.nextState = nextState
    }

    init(from buffer: inout ByteBuffer) throws
    {
        fatalError()
    }

    func write(to buffer: inout ByteBuffer)
    {
        buffer.write(varInt: VarInt(protocolVersion))
        buffer.write(string: serverAddress)
        buffer.write(integer: serverPort)
        buffer.write(varInt: nextState.rawValue)
    }
}
