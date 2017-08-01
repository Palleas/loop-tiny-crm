import Foundation

final class ContainerView: UIView {
    init() {
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func transition(to view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}

final class ContainerViewController: UIViewController {

    override func loadView() {
        view = ContainerView()
    }

    func transition(to child: UIViewController) {
        addChildViewController(child)

        (view as! ContainerView).transition(to: child.view)
    }

}
