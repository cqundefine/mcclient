import Foundation

enum RegistryError : Error
{
    case InvalidIndex(UInt32)
}

fileprivate let decoder = JSONDecoder()

class Registry<T>
{
    private let data: [UInt32: T]

    init(data: [UInt32: T])
    {
        self.data = data
    }

    init(fromJsonPath path: String) throws where T: Decodable
    {
        data = [UInt32: T](uniqueKeysWithValues: try decoder.decode([String: T].self, from: Data(contentsOf: URL(filePath: path))).map {
            (UInt32($0.key)!, $0.value)
        })
    }

    func get(_ index: UInt32) throws -> T
    {
        guard let value = data[index] else {
            throw RegistryError.InvalidIndex(index)
        }
        return value
    }
}

func loadRegistry() throws
{
    blockStateRegistry = try Registry<String>(fromJsonPath: "block_ids.json")
    entityTypeRegistry = try Registry<String>(fromJsonPath: "entity_type_ids.json")
}

var blockStateRegistry: Registry<String>?
var entityTypeRegistry: Registry<String>?
