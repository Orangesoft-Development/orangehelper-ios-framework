import Foundation

public extension String {
    
    var int: Int? {
        return Int(self)
    }
    
    var double: Double? {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","
        if let value = formatter.number(from: self)?.doubleValue {
            return value
        }
        formatter.decimalSeparator = "."
        return formatter.number(from: self)?.doubleValue
    }
    
    var isEmail: Bool {
        return match(regex: "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,})$")
    }
    
    var isValidUrl: Bool {
        return URL(string: self) != nil
    }
    
    var readingTime: TimeInterval {
        return readingTime(withSpeed: 200)
    }
    
    var url: URL? {
        return URL(string: self)
    }
    
    init(int: Int, groupingSeparator separator: String) {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = separator
        formatter.numberStyle = .decimal
        self = formatter.string(from: int as NSNumber) ?? ""
    }
    
    // MARK: - Reading Time
    
    func readingTime(withSpeed speed: Int) -> TimeInterval {
        var words = components(separatedBy: CharacterSet.whitespacesAndNewlines)
        words.removeAll(where: { $0 == "" })
        return Double(words.count) * (60.0 / Double(speed))
    }
    
    /// speed = words per minute. default speed is 200
    func readingTime(speed: UInt = 200) -> TimeInterval {
        return readingTime(withSpeed: Int(speed))
    }
    
    // MARK: - Regex
    
    func match(regex pattern: String) -> Bool {
        return range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    func firstMatch(ofRegex pattern: String) -> String? {
        if let range = range(of: pattern, options: .regularExpression, range: nil, locale: nil) {
            return String(self[range])
        }
        return nil
    }
    
    func allMatches(ofRegex pattern: String) -> [String] {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let matches = regex?.matches(in: self, options: [], range: NSRange(location: 0, length: utf16.count)) ?? []
        var substrings = [String]()
        for match in matches {
            if let range = Range(match.range, in: self) {
                substrings.append(String(self[range]))
            }
        }
        return substrings
    }
    
    func removeSpaces() -> String {
        return replacingOccurrences(of: " ", with: "")
    }
    
    func copyToPasteboard() {
        UIPasteboard.general.string = self
    }
    
    func date(withFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}
