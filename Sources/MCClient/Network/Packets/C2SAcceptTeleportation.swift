import NIOCore

struct C2SAcceptTeleportation: C2SPacket
{
    static let packetKey = PacketKey(packetID: 0x00, connectionState: .Play)

    let teleportID: UInt32

    func write(to buffer: inout ByteBuffer)
    {
        buffer.write(varInt: VarInt(teleportID))
    }
}
