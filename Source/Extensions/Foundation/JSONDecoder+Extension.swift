import Foundation

public extension JSONDecoder {
    func decode<T>(_ type: T.Type, fromJSON json: Any) throws -> T where T : Decodable {
        guard !(json is NSNull) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Parsed JSON error: json is NSNull"))
        }
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try decode(type, from: data)
    }
}

