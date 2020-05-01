import Foundation

public extension Date {
    
    var components: DateComponents {
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second, .nanosecond, .weekday, .weekOfMonth, .weekOfYear, .timeZone]
        return Calendar.current.dateComponents(components, from: self)
    }
    
    init?(from dateString: String, format: String, timezone: TimeZone? = nil) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let timezone = timezone {
            dateFormatter.timeZone = timezone
        }
        
        guard let date = dateFormatter.date(from: dateString) else { return nil }
        
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
    
    init?(from components: DateComponents) {
        guard let date = Calendar.current.date(from: components) else { return nil }
        
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
    
    func changed(_ changeBlock: (_ components: inout DateComponents) -> Void) -> Date? {
        var selfComponents = components
        changeBlock(&selfComponents)
        return Date(from: selfComponents)
    }
    
    func toString(withFormat format: String, timezone: TimeZone? = nil) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let timezone = timezone {
            dateFormatter.timeZone = timezone
        }
        return dateFormatter.string(from: self)
    }
    
    func toString(withFormatTemplate formatTemplate: String, timezone: TimeZone? = nil) -> String? {
        return toString(withFormat: DateFormatter.dateFormat(fromTemplate: formatTemplate, options: 0, locale: nil) ?? "", timezone: timezone)
    }
    
    
    func toString(withDateStyle dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, timezone: TimeZone? = nil) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        if let timezone = timezone {
            dateFormatter.timeZone = timezone
        }
        return dateFormatter.string(from: self)
    }
    
    func isEqualIgnoringTime(to otherDate: Date) -> Bool {
        let comp1 = components
        let comp2 = otherDate.components
        return (comp1.year == comp2.year) && (comp1.month == comp2.month) && (comp1.day == comp2.day)
    }
}

public extension Date {
    
    var calendar: Calendar {
        return Calendar(identifier: Calendar.current.identifier)
    }
    
    var weekOfMonth: Int {
        return calendar.component(.weekOfMonth, from: self)
    }
    
    var year: Int {
        get {
            return calendar.component(.year, from: self)
        }
        set {
            guard newValue > 0 else { return }
            let currentYear = calendar.component(.year, from: self)
            let yearsToAdd = newValue - currentYear
            if let date = calendar.date(byAdding: .year, value: yearsToAdd, to: self) {
                self = date
            }
        }
    }
    
    var month: Int {
        get {
            return calendar.component(.month, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .month, in: .year, for: self)!
            guard allowedRange.contains(newValue) else { return }
            
            let currentMonth = calendar.component(.month, from: self)
            let monthsToAdd = newValue - currentMonth
            if let date = calendar.date(byAdding: .month, value: monthsToAdd, to: self) {
                self = date
            }
        }
    }
    
    var day: Int {
        get {
            return calendar.component(.day, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .day, in: .month, for: self)!
            guard allowedRange.contains(newValue) else { return }
            
            let currentDay = calendar.component(.day, from: self)
            let daysToAdd = newValue - currentDay
            if let date = calendar.date(byAdding: .day, value: daysToAdd, to: self) {
                self = date
            }
        }
    }
    
    var weekday: Int {
        return calendar.component(.weekday, from: self)
    }
    
    var hour: Int {
        get {
            return calendar.component(.hour, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .hour, in: .day, for: self)!
            guard allowedRange.contains(newValue) else { return }
            
            let currentHour = calendar.component(.hour, from: self)
            let hoursToAdd = newValue - currentHour
            if let date = calendar.date(byAdding: .hour, value: hoursToAdd, to: self) {
                self = date
            }
        }
    }
    
    var minute: Int {
        get {
            return calendar.component(.minute, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .minute, in: .hour, for: self)!
            guard allowedRange.contains(newValue) else { return }
            
            let currentMinutes = calendar.component(.minute, from: self)
            let minutesToAdd = newValue - currentMinutes
            if let date = calendar.date(byAdding: .minute, value: minutesToAdd, to: self) {
                self = date
            }
        }
    }
    
    var second: Int {
        get {
            return calendar.component(.second, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .second, in: .minute, for: self)!
            guard allowedRange.contains(newValue) else { return }
            
            let currentSeconds = calendar.component(.second, from: self)
            let secondsToAdd = newValue - currentSeconds
            if let date = calendar.date(byAdding: .second, value: secondsToAdd, to: self) {
                self = date
            }
        }
    }
    
    var millisecond: Int {
        get {
            return calendar.component(.nanosecond, from: self) / 1000000
        }
        set {
            let nanoSeconds = newValue * 1000000
            let allowedRange = calendar.range(of: .nanosecond, in: .second, for: self)!
            guard allowedRange.contains(nanoSeconds) else { return }
            
            if let date = calendar.date(bySetting: .nanosecond, value: nanoSeconds, of: self) {
                self = date
            }
        }
    }
    
    var nanosecond: Int {
        get {
            return calendar.component(.nanosecond, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .nanosecond, in: .second, for: self)!
            guard allowedRange.contains(newValue) else { return }
            
            let currentNanoseconds = calendar.component(.nanosecond, from: self)
            let nanosecondsToAdd = newValue - currentNanoseconds
            
            if let date = calendar.date(byAdding: .nanosecond, value: nanosecondsToAdd, to: self) {
                self = date
            }
        }
    }
    
    var isFuture: Bool {
        return self > Date()
    }
    
    var isPast: Bool {
        return self < Date()
    }
    
    var isToday: Bool {
        return calendar.isDateInToday(self)
    }
    
    var isCurrentWeek: Bool {
        return calendar.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    var isCurrentMonth: Bool {
        return calendar.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    var isCurrentYear: Bool {
        return calendar.isDate(self, equalTo: Date(), toGranularity: .year)
    }
}
