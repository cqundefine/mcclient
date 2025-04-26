import NIOCore

struct PacketKey : Hashable
{
    let packetID: UInt32
    let connectionState: ConnectionState
}

protocol Packet
{
    static var packetKey: PacketKey { get }

    init(from buffer: inout ByteBuffer) throws
    func write(to buffer: inout ByteBuffer)
}

typealias PacketHandler<T: Packet> = (T, TCPClient) throws -> Void

class PacketRegistry
{
    private var packets: [PacketKey: (type: Packet.Type, handler: (Packet, TCPClient) throws -> ())] = [:]

    func register<T: Packet>(_ packetType: T.Type, handler: @escaping PacketHandler<T>)
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
