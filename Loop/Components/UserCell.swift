import Foundation
import UIKit

final class UserCell: UICollectionViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var displayName: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()

        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = avatar.frame.width / 2
    }
}
