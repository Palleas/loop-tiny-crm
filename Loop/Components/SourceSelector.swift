import UIKit

@IBDesignable
final class SourceSelector: UIView {

    let twitter: UIButton = {
        let button = UIButton(type: .custom)

        return button
    }()
    let email = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(twitter)
        addSubview(email)

        backgroundColor = .red
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addSubview(twitter)
        addSubview(email)

        backgroundColor = .red

    }

}
