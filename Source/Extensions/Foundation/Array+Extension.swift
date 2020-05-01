public extension Array {
    
    subscript(safe index: Index) -> Element? {
        return 0..<count ~= index ? self[index] : nil
    }
    
}

public extension Array where Element: Equatable {
    
    mutating func remove(_ element: Element) {
        for index in (0..<count).reversed() where self[index] == element {
            remove(at: index)
        }
    }
}
