import Foundation

public let PointerDidChangeNotification = "OFPointerDidChangeNotification"

public class Pointer<T> {
    public var value: T? {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(PointerDidChangeNotification), object: self)
        }
    }
    
    public init(value: T) {
        self.value = value
    }
}
