import Foundation

enum CompressionSchema : UInt8
{
    case GZip = 1
    case Zlib = 2
    case Uncompressed = 3
    case LZ4 = 4
    case Custom = 127
}

class AnvilFile
{
    let reader: DataReader

    init(data: Data)
    {
        reader = DataReader(data: data)
    }

    func readFirstChunk() throws -> Data
    {
        let location: UInt32 = try reader.read()
        let offset = location >> 8
        try reader.seek(to: Int(offset * 0x1000))
        let size: Int32 = try reader.read()

        let compressionSchema: CompressionSchema = try reader.read()
        assert(compressionSchema == .Uncompressed)

        let chunkData = try reader.read(dataSize: Int(size))
        return chunkData
    }
}
