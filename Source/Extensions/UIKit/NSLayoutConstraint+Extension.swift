import UIKit

public extension NSLayoutConstraint {
    
    @IBInspectable var constantInPixels: Int {
        set { constant = CGFloat(newValue) / UIScreen.main.scale }
        get { return Int(constant * UIScreen.main.scale) }
    }
    
}
