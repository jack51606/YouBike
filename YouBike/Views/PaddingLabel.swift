import UIKit

class PaddingLabel: UILabel {

    public var padding: UIEdgeInsets = .zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        var width = super.intrinsicContentSize.width
        var height = super.intrinsicContentSize.height
        width += padding.left + padding.right
        height += padding.top + padding.bottom
        return CGSize(width: width, height: height)
    }
}
