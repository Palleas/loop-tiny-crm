import Foundation

final class ActivityCell: UICollectionViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var borderContainer: UIView! {
        didSet {
            guard let borderContainer = borderContainer else { return }

            borderContainer.layer.borderColor = UIColor(named: "AcitivtyBorderColor")?.cgColor
            borderContainer.layer.borderWidth = 1
            borderContainer.clipsToBounds = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        borderContainer.layer.cornerRadius = borderContainer.frame.width / 2
    }

}
