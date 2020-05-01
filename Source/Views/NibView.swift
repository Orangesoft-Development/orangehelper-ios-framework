import UIKit

open class NibView: UIView {
    
    @IBInspectable public private(set) var nibName: String?
    private var contentView: UIView?
    private var _intrinsicContentSize = CGSize.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }
    
    init(nibName: String?) {
        super.init(frame: CGRect.zero)
        self.nibName = nibName
        commonSetup()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        commonSetup()
    }
    
    override open var intrinsicContentSize: CGSize {
        set {
            _intrinsicContentSize = intrinsicContentSize
            invalidateIntrinsicContentSize()
        }
        get {
            return _intrinsicContentSize
        }
    }
    
    private func commonSetup() {
        if nibName == nil {
            nibName = String(describing: type(of: self).self)
        }
        guard let first = Bundle.main.loadNibNamed(nibName ?? "", owner: self, options: nil)?.first as? UIView else {
            return
        }
        
        contentView = first
        
        intrinsicContentSize = first.bounds.size
        addSubview(first)
        // bind contentView to self
        first.bindToSuperview()
    }
}
