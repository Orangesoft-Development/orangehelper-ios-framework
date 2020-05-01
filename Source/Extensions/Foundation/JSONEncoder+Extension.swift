import Foundation

public extension JSONEncoder {
    func encodeToJSON<T>(_ value: T) throws -> Any where T : Encodable {
        let data = try encode(value)
        return try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
    }
}
