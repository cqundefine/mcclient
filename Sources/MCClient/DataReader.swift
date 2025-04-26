import Foundation

enum DataReaderError : Error
{
    case SeekOutOfBounds
    case NotEnoughData
    case InvalidDataSize(Int)
    case InvalidEnumValue(Any.Type, Any)
    case TooMuchDataForVarInt
}

class DataReader
{
    private let data: Data
    private(set) var index = 0

    init(data: Data)
    {
        self.data = data
    }

    init(data: [UInt8])
    {
        self.data = Data(data)
    }

    func empty() -> Bool
    {
        return index == data.count
    }

    func peek() throws -> UInt8
    {
        guard index < data.count else {
            throw DataReaderError.NotEnoughData
        }
        return data[index]
    }

    func seek(to index: Int) throws
    {
        guard index >= 0 && index <= data.count else {
            throw DataReaderError.SeekOutOfBounds
        }
        self.index = index
    }

    func read<T: FixedWidthInteger>() throws -> T
    {
        let byteCount = MemoryLayout<T>.size
        guard index + byteCount <= data.count else {
            throw DataReaderError.NotEnoughData
        }

        let bytes = data[index..<index + byteCount]
        index += byteCount

        return bytes.reversed().withUnsafeBytes {
            $0.load(as: T.self)
        }
    }

    // FIXME: This is the exact same implementation as the one above
    func read<T: BinaryFloatingPoint>() throws -> T
    {
        let byteCount = MemoryLayout<T>.size
        guard index + byteCount <= data.count else {
            throw DataReaderError.NotEnoughData
        }

        let bytes = data[index..<index + byteCount]
        index += byteCount

        return bytes.reversed().withUnsafeBytes {
            $0.load(as: T.self)
        }
    }

    func read<T>() throws -> T where T: RawRepresentable, T.RawValue: FixedWidthInteger
    {
        let rawValue: T.RawValue = try read()
        guard let value = T(rawValue: rawValue) else {
            throw DataReaderError.InvalidEnumValue(T.self, rawValue)
        }
        return value
    }

    func read() throws -> VarInt
    {
        var value: UInt32 = 0
        var position: UInt8 = 0
        
        while true {
            let currentByte: UInt8 = try read()
            value |= (UInt32(currentByte) & 0x7F) << position

            if currentByte & 0x80 == 0 {
                break
            }

            position += 7

            if position >= 32 {
                throw DataReaderError.TooMuchDataForVarInt
            }
        }

        return VarInt(value)
    }

    func read<T: FixedWidthInteger>(arraySize: Int) throws -> [T]
    {
        var array: [T] = []
        for _ in 0..<arraySize {
            array.append(try read())
        }
        return array
    }

    func read(dataSize: Int) throws -> Data
    {
        guard dataSize >= 0 else {
            throw DataReaderError.InvalidDataSize(dataSize)
        }

        guard index + dataSize <= data.count else {
            throw DataReaderError.NotEnoughData
        }

        let bytes = data[index..<index + dataSize]
        index += dataSize

        return Data(bytes)
    }
}
