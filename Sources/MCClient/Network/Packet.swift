import NIOCore

struct PacketKey : Hashable
{
    let packetID: UInt32
    let connectionState: ConnectionState
}

protocol C2SPacket
{
    static var packetKey: PacketKey { get }
    func write(to buffer: inout ByteBuffer)
}

protocol S2CPacket
{
    static var packetKey: PacketKey { get }
    init(from buffer: inout ByteBuffer) throws
}

typealias PacketHandler<T: S2CPacket> = (T, TCPClient) throws -> Void

class PacketRegistry
{
    private var packets: [PacketKey: (type: S2CPacket.Type, handler: (S2CPacket, TCPClient) throws -> ())] = [:]

    func register<T: S2CPacket>(_ packetType: T.Type, handler: @escaping PacketHandler<T>)
    {
        guard packets[packetType.packetKey] == nil else {
            fatalError("Tried to register already registered packet")
        }
        packets[packetType.packetKey] = (packetType, { packet, client in try handler(packet as! T, client) })
    }

    func handlePacket(packetID: UInt32, buffer: inout ByteBuffer, client: TCPClient) throws
    {
        guard let packetInfo = packets[PacketKey(packetID: packetID, connectionState: client.state)] else {
            print("Unknown packet ID: 0x\(String(packetID, radix: 16, uppercase: true))")
            return
        }
        print("Handling packet ID: 0x\(String(packetID, radix: 16, uppercase: true))")
        let packet = try packetInfo.type.init(from: &buffer)
        try packetInfo.handler(packet, client)
    }
}
