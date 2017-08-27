import Foundation

final class ListLeadsViewController: UITableViewController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        tabBarItem = UITabBarItem(title: "All leads", image: Asset.addressBook.image, selectedImage: nil)
    }
}
