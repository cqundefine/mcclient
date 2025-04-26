import Foundation
import NIOCore

struct S2CChunkDataLight: S2CPacket
{
    static let packetKey = PacketKey(packetID: 0x27, connectionState: .Play)

    let chunkX: Int32
    let chunkZ: Int32
    let chunkData: Data

    init(from buffer: inout ByteBuffer) throws
    {
        chunkX = buffer.read()
        chunkZ = buffer.read()
        
        let heightmapCount: VarInt = buffer.read()
        for _ in 0..<heightmapCount.value {
            let _: VarInt = buffer.read()
            let length: VarInt = buffer.read()
            let _ = buffer.readBytes(length: Int(length.value) * 8)
        }

        let dataLength: VarInt = buffer.read()
        chunkData = Data(buffer.readBytes(length: Int(dataLength.value))!)
    }
}
