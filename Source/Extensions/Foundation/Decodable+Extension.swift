import Foundation

public extension Decodable {
    static func decode(json: Any) throws -> Self {
        return try JSONDecoder().decode(Self.self, fromJSON: json)
    }
}
