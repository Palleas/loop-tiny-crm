import Foundation

final class ActivityCell: UICollectionViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!

    override var isSelected: Bool {
        didSet {
            if isSelected {
                borderContainer.backgroundColor = ColorName.grapefruit.color
                icon?.tintColor = .white
            } else {
                borderContainer.backgroundColor = .white
                icon?.tintColor = .black
            }
        }
    }

    @IBOutlet weak var borderContainer: UIView! {
        didSet {
            guard let borderContainer = borderContainer else { return }

            borderContainer.layer.borderColor = ColorName.white.color.cgColor
            borderContainer.layer.borderWidth = 1
            borderContainer.clipsToBounds = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        borderContainer.layer.cornerRadius = borderContainer.frame.width / 2
    }

}
