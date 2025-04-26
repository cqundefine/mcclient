protocol Palette
{
    init(reader: DataReader) throws
    func getIndexFor(_ index: UInt32) throws -> UInt32
}

enum PaletteError : Error
{
    case InvalidIndex(UInt32)
}

typealias PaletteStrategy = (DataReader) throws -> Palette

struct SingleValuedPalette : Palette
{
    let value: UInt32

    init(reader: DataReader) throws
    {
        let varInt: VarInt = try reader.read()
        value = varInt.value
    }

    func getIndexFor(_ index: UInt32) throws -> UInt32
    {
        return value
    }
}

func singleValuedPaletteStrategy(reader: DataReader) throws -> Palette
{
    return try SingleValuedPalette(reader: reader)
}

struct IndirectPalette : Palette
{
    var decodedPalette: [UInt32] = []

    init(reader: DataReader) throws
    {
        let paletteLength: VarInt = try reader.read()
        
        for _ in 0..<paletteLength.value {
            let entry: VarInt = try reader.read()
            decodedPalette.append(entry.value)
        }    
    }
    
    func getIndexFor(_ index: UInt32) throws -> UInt32
    {
        guard index < decodedPalette.count else {
            throw PaletteError.InvalidIndex(index)
        }
        return decodedPalette[Int(index)]
    }
}

func indirectPaletteStrategy(reader: DataReader) throws -> Palette
{
    return try IndirectPalette(reader: reader)
}

struct DirectPalette : Palette
{
    init(reader: DataReader) throws
    {    
    }

    func getIndexFor(_ index: UInt32) throws -> UInt32
    {
        return index    
    }
}

func directPaletteStrategy(reader: DataReader) throws -> Palette
{
    return try DirectPalette(reader: reader)
}
