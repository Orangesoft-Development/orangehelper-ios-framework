import UIKit

public extension UINavigationController {
    enum Constant {
        static let backgroundImageViewKey = "navigationControllerBackgroundImageViewKey"
        static let popGestureKey = "navigationControllerPopGestureKey"
        static let systemPopGestureDelegate = "systemPopGestureDelegate"
    }
    
    private var backgroundImageView: UIImageView {
        guard let imageView = userInfo[Constant.backgroundImageViewKey] as? UIImageView else {
            let imageView = UIImageView(frame: view.bounds)
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imageView.contentMode = .scaleAspectFill
            view.insertSubview(imageView, at: 0)
            userInfo[Constant.backgroundImageViewKey] = imageView
            return imageView
        }
        return imageView
    }
    
    @IBInspectable var navBarImage: UIImage? {
        set { navigationBar.setBackgroundImage(newValue, for: .default) }
        get { return navigationBar.backgroundImage(for: .default) }
    }
    
    @IBInspectable var navBarShadow: Bool {
        set {
            navBarImage = newValue ? nil : UIImage()
            navigationBar.shadowImage = newValue ? nil : UIImage()
        }
        get {
            return navigationBar.shadowImage == nil
        }
    }
    
    @IBInspectable var navBarTransparent: Bool {
        set {
            navBarImage = newValue ? UIImage() : nil
            navigationBar.isTranslucent = newValue
        }
        get {
            return navigationBar.isTranslucent && navBarImage == nil
        }
    }
    
    @IBInspectable var backgroundImage: UIImage? {
        set { backgroundImageView.image = newValue }
        get { return backgroundImageView.image }
    }
    
    @IBInspectable var popGesture: Bool {
        set {
            userInfo[Constant.popGestureKey] = newValue
        }
        get {
            guard let isEnabled = userInfo[Constant.popGestureKey] as? Bool else {
                return false
            }
            return isEnabled
        }
    }
    
    static func swizzleNavigationControllerMethods() {
        swizzleMethod(#selector(viewDidLoad), withMethod: #selector(swizzleViewDidLoad))
    }
    
    @objc private func swizzleViewDidLoad() {
        swizzleViewDidLoad()
        setupPopGesture()
    }
    
    func setupPopGesture() {
        if (delegate is NavigationAnimator) {
            let navigationAnimator = delegate as? NavigationAnimator
            navigationAnimator?.setInteractivePopGestureOwner(popGesture ? self : nil)
            // disable system pop recognizer
            userInfo[Constant.systemPopGestureDelegate] = nil
            interactivePopGestureRecognizer?.delegate = nil
            interactivePopGestureRecognizer?.isEnabled = false
        } else {
            // setup system pop recognizer
            let systemPopGestureDelegate = popGesture ? NavigationAnimator() : nil
            systemPopGestureDelegate?.setInteractivePopGestureOwner(self)
            userInfo[Constant.systemPopGestureDelegate] = systemPopGestureDelegate // save strong reference
            interactivePopGestureRecognizer?.delegate = systemPopGestureDelegate
            interactivePopGestureRecognizer?.isEnabled = systemPopGestureDelegate != nil
        }
        
    }
}

class NavigationAnimator: NSObject {
    
    private weak var popGestureOwner: UINavigationController?
    private var popGestureRecognizer: UIGestureRecognizer?
    private var interactiveTransition: UIPercentDrivenInteractiveTransition?
    private var navigationOperation: UINavigationController.Operation?
    
    func setInteractivePopGestureOwner(_ interactivePopGestureOwner: UINavigationController?) {
        if popGestureOwner != interactivePopGestureOwner {
            if interactivePopGestureOwner != nil {
                let recognizer = UIScreenEdgePanGestureRecognizer()
                recognizer.edges = .left
                recognizer.delegate = self
                recognizer.addTarget(self, action: #selector(handlePanGesture(recognizer:)))
                interactivePopGestureOwner?.view.addGestureRecognizer(recognizer)
                popGestureRecognizer = recognizer
                popGestureOwner = interactivePopGestureOwner
            } else {
                if let gestureRecognizer = popGestureRecognizer {
                    gestureRecognizer.view?.removeGestureRecognizer(gestureRecognizer)
                }
                popGestureRecognizer = nil
                popGestureOwner = nil
            }
        }
    }
    
    @objc func handlePanGesture(recognizer: UIScreenEdgePanGestureRecognizer) {
        guard let width = recognizer.view?.bounds.size.width else { return }
        
        var progress = recognizer.translation(in: recognizer.view).x / width
        progress = min(1.0, max(0.0, progress))
        switch recognizer.state {
        case .began:
            interactiveTransition = UIPercentDrivenInteractiveTransition()
            interactiveTransition?.completionCurve = .easeOut
            popGestureOwner?.popViewController(animated: true)
        case .changed:
            interactiveTransition?.update(progress)
        case .ended, .cancelled:
            if progress > 0.35 || recognizer.velocity(in: recognizer.view).x > 1000 {
                interactiveTransition?.completionSpeed = 2 // part of fix fast cancel transition animation
                interactiveTransition?.finish()
            } else {
                interactiveTransition?.cancel()
            }
            interactiveTransition = nil
        default:
            break
        }
    }
    
}

extension NavigationAnimator: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let count = popGestureOwner?.viewControllers.count, let topVC = popGestureOwner?.topViewController else { return false }
        return count > 1 && !topVC.isAppearing
    }
    
}

extension NavigationAnimator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        navigationOperation = operation
        return self
    }
    
}

extension NavigationAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        guard let context = transitionContext else { return 0.3 }
        return 0.3 * TimeInterval(context.isInteractive ? 3 : 1)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) { }
}
