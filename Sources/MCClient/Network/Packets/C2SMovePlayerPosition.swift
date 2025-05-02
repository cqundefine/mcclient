import Foundation
import NIOCore

struct C2SMovePlayerPosition: C2SPacket
{
    static let packetKey = PacketKey(packetID: 0x1C, connectionState: .Play)

    let x: Double
    let y: Double
    let z: Double
    let flags: Int8

    func write(to buffer: inout ByteBuffer)
    {
        buffer.write(float: x)
        buffer.write(float: y)
        buffer.write(float: z)
        buffer.write(integer: flags)
    }
}
