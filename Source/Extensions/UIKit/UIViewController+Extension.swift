import UIKit

public extension UIViewController {
    
    typealias SeguePreparationBlock = (UIStoryboardSegue?) -> Void

    private enum Constant {
        static let preparationBlock = "preparationBlock"
        static let appearingFlag = "appearingFlag"
        static let disappearingFlag = "disappearingFlag"
    }
    
    var isAppearing: Bool {
        return userInfo[Constant.appearingFlag] != nil
    }
    
    var isDisappearing: Bool {
        return userInfo[Constant.disappearingFlag] != nil
    }
    
    @IBAction func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dismiss() {
        presentingViewController?.dismiss(animated: true)
    }
    
    func performSegue(withIdentifier identifier: String?, preparation: @escaping SeguePreparationBlock) {
        userInfo[Constant.preparationBlock] = preparation
        performSegue(withIdentifier: identifier ?? "", sender: nil)
    }

    static func swizzleViewControllerMethods() {
        swizzleMethod(#selector(viewWillAppear(_:)), withMethod: #selector(swizzleViewWillAppear(animated:)))
        swizzleMethod(#selector(viewDidAppear(_:)), withMethod: #selector(swizzleViewDidAppear(animated:)))
        swizzleMethod(#selector(viewWillDisappear(_:)), withMethod: #selector(swizzleViewWillDisappear(animated:)))
        swizzleMethod(#selector(viewDidDisappear(_:)), withMethod: #selector(swizzleViewDidDisappear(animated:)))
        swizzleMethod(#selector(prepare(for:sender:)), withMethod: #selector(swizzlePrepareForSegue(segue:sender:)))
    }
    
    @objc private func swizzleViewWillAppear(animated: Bool) {
        swizzleViewWillAppear(animated: animated)
        userInfo[Constant.appearingFlag] = true
    }
    
    @objc private func swizzleViewDidAppear(animated: Bool) {
        swizzleViewDidAppear(animated: animated)
        userInfo.removeObject(forKey: Constant.appearingFlag)
    }
    
    @objc private func swizzleViewWillDisappear(animated: Bool) {
        swizzleViewWillDisappear(animated: animated)
        userInfo[Constant.disappearingFlag] = true
    }
    
    @objc private func swizzleViewDidDisappear(animated: Bool) {
        swizzleViewDidDisappear(animated: animated)
        userInfo.removeObject(forKey: Constant.disappearingFlag)
    }
    
    @objc private func swizzlePrepareForSegue(segue: UIStoryboardSegue, sender: Any?) {
        if let block = userInfo[Constant.preparationBlock] as? SeguePreparationBlock {
            block(segue)
            userInfo.removeObject(forKey: Constant.preparationBlock)
        }
        swizzlePrepareForSegue(segue: segue, sender: sender)
    }
}
