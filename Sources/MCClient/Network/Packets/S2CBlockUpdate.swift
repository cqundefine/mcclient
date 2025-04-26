import NIOCore

struct S2CBlockUpdate: Packet
{
    static var packetKey = PacketKey(packetID: 0x08, connectionState: .Play)

    let position: Vector3
    let blockID: UInt32

    init(from buffer: inout ByteBuffer) throws
    {
        position = buffer.read()
        let blockIDVar: VarInt = buffer.read()
        blockID = blockIDVar.value
    }

    func write(to buffer: inout ByteBuffer)
    {
        fatalError()
    }
}
