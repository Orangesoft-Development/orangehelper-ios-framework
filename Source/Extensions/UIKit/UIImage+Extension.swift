import UIKit

public extension UIImage {
    
    var isOpaque: Bool {
        guard let alphaInfo = cgImage?.alphaInfo else { return false }
        return alphaInfo == .first || alphaInfo == .last || alphaInfo == .premultipliedFirst || alphaInfo == .premultipliedLast
    }

    convenience init?(color: UIColor?, size: CGSize) {
        self.init(color: color, size: size, transparentInsets: .zero)
    }
    
    convenience init?(color: UIColor?, size: CGSize, transparentInsets insets: UIEdgeInsets) {
        let coloredRect = CGRect(x: insets.left,
                                 y: insets.top,
                                 width: size.width - insets.left - insets.right,
                                 height: size.height - insets.top - insets.bottom)
        UIGraphicsBeginImageContextWithOptions(size, insets == .zero, 0)
        color?.setFill()
        UIRectFill(coloredRect)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = resultImage?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    convenience init?(from view: UIView?) {
        UIGraphicsBeginImageContextWithOptions(view?.bounds.size ?? .zero, false, 0)
        view?.drawHierarchy(in: view?.bounds ?? .zero, afterScreenUpdates: true)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = resultImage?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func scaled(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    func scaled(toFit size: CGSize) -> UIImage? {
        let imageAspectRatio = size.width / size.height
        let canvasAspectRatio = size.width / size.height
        let resizeFactor = imageAspectRatio > canvasAspectRatio ? size.width / size.width : size.height / size.height
        let scaledSize = CGSize(width: size.width * resizeFactor, height: size.height * resizeFactor)
        let origin = CGPoint(x: (size.width - scaledSize.width) / 2.0, y: (size.height - scaledSize.height) / 2.0)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(x: origin.x, y: origin.y, width: scaledSize.width, height: scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func scaled(toFill size: CGSize) -> UIImage? {
        let imageAspectRatio = size.width / size.height
        let canvasAspectRatio = size.width / size.height
        let resizeFactor = imageAspectRatio > canvasAspectRatio ? size.height / size.height : size.width / size.width
        let scaledSize = CGSize(width: size.width * resizeFactor, height: size.height * resizeFactor)
        let origin = CGPoint(x: (size.width - scaledSize.width) / 2.0, y: (size.height - scaledSize.height) / 2.0)
        
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0)
        draw(in: CGRect(x: origin.x, y: origin.y, width: scaledSize.width, height: scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func rounded(withCornerRadius cornerRadius: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let clippingPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        clippingPath.addClip()
        draw(in: bounds)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage
    }
    
    func roundedIntoCircle() -> UIImage? {
        let radius: CGFloat = min(size.width, size.height) / 2.0
        var squareImage: UIImage? = self
        if size.width != size.height {
            let squareDimension = min(size.width, size.height)
            let squareSize = CGSize(width: squareDimension, height: squareDimension)
            squareImage = scaled(toFill: squareSize)
        }
        return squareImage?.rounded(withCornerRadius: radius)
    }
    
    func withNormalizedOrientation() -> UIImage? {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
