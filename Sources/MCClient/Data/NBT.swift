import Foundation

struct NBTTag
{
    let name: String
    let value: NBTValue
}

enum NBTValue
{
    case Byte(Int8)
    case Short(Int16)
    case Int(Int32)
    case Long(Int64)
    case Float(Float)
    case Double(Double)
    case ByteArray([UInt8])
    case String(String)
    case List([NBTValue])
    case Compound([NBTTag])
    case IntArray([Int32])
    case LongArray([Int64])

    func findCompoundChild(name: String) throws -> NBTValue
    {
        guard case let .Compound(tags) = self else {
                throw NBTError.WrongValueType
        }

        for tag in tags {
            if tag.name == name {
                return tag.value
            }
        }
        throw NBTError.ChildNotFound
    }

    func byte() throws -> Int8 { guard case let .Byte(value) = self else { throw NBTError.WrongValueType }; return value }
    func short() throws -> Int16 { guard case let .Short(value) = self else { throw NBTError.WrongValueType }; return value }
    func int() throws -> Int32 { guard case let .Int(value) = self else { throw NBTError.WrongValueType }; return value }
    func long() throws -> Int64 { guard case let .Long(value) = self else { throw NBTError.WrongValueType }; return value }
    func float() throws -> Float { guard case let .Float(value) = self else { throw NBTError.WrongValueType }; return value }
    func double() throws -> Double { guard case let .Double(value) = self else { throw NBTError.WrongValueType }; return value }
    func byteArray() throws -> [UInt8] { guard case let .ByteArray(value) = self else { throw NBTError.WrongValueType }; return value }
    func string() throws -> String { guard case let .String(value) = self else { throw NBTError.WrongValueType }; return value }
    func list() throws -> [NBTValue] { guard case let .List(value) = self else { throw NBTError.WrongValueType }; return value }
    func intArray() throws -> [Int32] { guard case let .IntArray(value) = self else { throw NBTError.WrongValueType }; return value }
    func longArray() throws -> [Int64] { guard case let .LongArray(value) = self else { throw NBTError.WrongValueType }; return value }
}

enum NBTError : Error
{
    case InvalidString(Data)
    case InvalidTag(UInt8)
    case ChildNotFound
    case WrongValueType
}

class NBTParser
{
    let reader: DataReader

    init(data: Data)
    {
        reader = DataReader(data: data)
    }

    init(data: [UInt8])
    {
        reader = DataReader(data: data)
    }

    init(reader: DataReader)
    {
        self.reader = reader
    }

    func parse() throws -> NBTTag
    {
        let tag: UInt8 = try reader.read()
        let name = try parseString()
        let value = try parseValue(tag: tag)

        return NBTTag(name: name, value: value)
    }

    private func parseString() throws -> String
    {
        let size: UInt16 = try reader.read()
        let bytes = try reader.read(dataSize: Int(size))
        guard let string = String(bytes: bytes, encoding: .utf8) else {
            throw NBTError.InvalidString(bytes)
        }
        return string
    }

    private func parseValue(tag: UInt8) throws -> NBTValue
    {
        switch tag {
            case 1:
                return .Byte(try reader.read())
            case 2:
                return .Short(try reader.read())
            case 3:
                return .Int(try reader.read())
            case 4:
                return .Long(try reader.read())
            case 5:
                return .Float(try reader.read())
            case 6:
                return .Double(try reader.read())

            case 7:
                let size: Int32 = try reader.read()
                var array: [UInt8] = []
                for _ in 0..<size {
                    array.append(try reader.read())
                }
                return .ByteArray(array)

            case 8:
                return .String(try parseString())

            case 9:
                let tag: UInt8 = try reader.read()
                let length: Int32 = try reader.read()

                var values: [NBTValue] = []
                for _ in 0..<length {
                    values.append(try parseValue(tag: tag))
                }
                return .List(values)

            case 10:
                var tags: [NBTTag] = []
                while try reader.peek() != 0 {
                    tags.append(try parse())
                }

                let _: UInt8 = try reader.read()
                return .Compound(tags)
            
            case 11:
                let size: Int32 = try reader.read()
                var array: [Int32] = []
                for _ in 0..<size {
                    array.append(try reader.read())
                }
                return .IntArray(array)
            
            case 12:
                let size: Int32 = try reader.read()
                var array: [Int64] = []
                for _ in 0..<size {
                    array.append(try reader.read())
                }
                return .LongArray(array)

            default:
                throw NBTError.InvalidTag(tag)
        }
    }
}
