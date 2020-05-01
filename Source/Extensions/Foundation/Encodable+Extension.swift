import Foundation

public extension Encodable {
    func encode() throws -> Any {
        return try JSONEncoder().encodeToJSON(self)
    }
}
