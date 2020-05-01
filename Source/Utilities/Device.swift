import Foundation

final public class Device {
    
    class public var screenScale: CGFloat {
        return UIScreen.main.scale
    }
    
    class public var screenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    class public var screenHeight: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    class public var screenMaxLength: CGFloat {
        return max(screenWidth, screenHeight)
    }
    
    class public var screenMinLength: CGFloat {
        return min(screenWidth, screenHeight)
    }
    
    class public var screenPixelLength: CGFloat {
        return 1.0 / screenScale
    }
    
    class public var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    class public var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    class public var pathToDocuments: String? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    class public var pathToCaches: String? {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
    }
    
    class public var systemVersion: String {
        return UIDevice.current.systemVersion
    }
}
