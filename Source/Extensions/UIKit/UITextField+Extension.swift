import UIKit

public extension UITextField {
    
    var hasValidEmail: Bool {
        return text?.isEmail ?? false
    }
    
    func clear() {
        text = ""
        attributedText = NSAttributedString(string: "")
    }
    
}
