import UIKit

final class SourceSelector: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addTarget(self, action: #selector(toggle), for: .touchUpInside)

        layer.borderColor = UIColor.lpWhite.cgColor
        layer.borderWidth = 1
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = .lpGrapefruit
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

    @objc
    func toggle() {
        self.isSelected = !self.isSelected
    }
}
