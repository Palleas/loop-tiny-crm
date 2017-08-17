import UIKit


final class SourceSelector: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        layer.borderColor = ColorName.white.color.cgColor
        layer.borderWidth = 1
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = ColorName.grapefruit.color
                tintColor = .white
                layer.borderWidth = 0
            } else {
                backgroundColor = .clear
                tintColor = .black
                layer.borderWidth = 1
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.width / 2
    }
}
