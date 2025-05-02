import Foundation
import NIOCore

extension ByteBuffer
{
    mutating func read<T: FixedWidthInteger>() -> T?
    {
        readInteger(endianness: .big, as: T.self)
    }

    mutating func read<T: FixedWidthInteger>() -> T
    {
        return readInteger(endianness: .big, as: T.self)!
    }

    mutating func read<T: BinaryFloatingPoint>() -> T
    {
        // FIXME: This is not endian correct
        readBytes(length: MemoryLayout<T>.size)!.reversed().withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> T in
                let value = ptr.baseAddress!.assumingMemoryBound(to: T.self).pointee
                return value
            }
    }

    mutating func read() -> Bool
    {
        let byte: UInt8 = read()
        return byte == 0x01
    }

    mutating func read() -> VarInt
    {
        var value: UInt32 = 0
        var position: UInt8 = 0
        
        while true {
            let currentByte: UInt8 = readInteger()!
            value |= (UInt32(currentByte) & 0x7F) << position

            if currentByte & 0x80 == 0 {
                break
            }

            position += 7

            if position >= 32 {
                fatalError()
            }
        }

        return VarInt(value)
    }

    mutating func read() -> String
    {
        let length: VarInt = read()
        let bytes = readBytes(length: Int(length.value))!
        return String(bytes: bytes, encoding: .utf8)!
    }

    mutating func read() -> UUID
    {
        return NSUUID(uuidBytes: readBytes(length: 16)!) as UUID
    }

    mutating func read() -> Vector3
    {
        let packed: UInt64 = read()
        let y = signExtend(bitCut(packed, position: 0, count: 12), bits: 12)
        let z = signExtend(bitCut(packed, position: 12, count: 26), bits: 26)
        let x = signExtend(bitCut(packed, position: 38, count: 26), bits: 26)
        return Vector3(Float(x), Float(y), Float(z))
    }

    mutating func write<T: FixedWidthInteger>(integer: T)
    {
        writeInteger(integer, endianness: .big)
    }

    mutating func write<T: BinaryFloatingPoint>(float: T)
    {
        switch MemoryLayout<T>.size {
            case 4:
                let bits = unsafeBitCast(float, to: UInt32.self)
                writeInteger(bits, endianness: .big)
            case 8:
                let bits = unsafeBitCast(float, to: UInt64.self)
                writeInteger(bits, endianness: .big)
            default:
                fatalError("Unsupported BinaryFloatingPoint size")
        }
    }

    mutating func write(varInt: VarInt)
    {
        var remaining = varInt.value
        while true {
            if (remaining & ~0x7F) == 0 {
                writeInteger(UInt8(remaining))
                return
            }

            writeInteger(UInt8(remaining & 0x7F) | 0x80)

            remaining >>= 7
        }
    }

    mutating func write(string: String)
    {
        write(varInt: VarInt(UInt32(string.utf8.count)))
        writeBytes(string.utf8)
    }

    mutating func write(uuid: UUID)
    {
        writeBytes(withUnsafePointer(to: uuid) {
            Data(bytes: $0, count: MemoryLayout<UUID>.size)
        })
    }
}
