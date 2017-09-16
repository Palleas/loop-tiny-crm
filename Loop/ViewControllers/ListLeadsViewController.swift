import Foundation
import LoopKit

final class ListLeadsViewController: UITableViewController {

    var leads = [TwitterUser]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        tabBarItem = UITabBarItem(title: "All leads", image: Asset.addressBook.image, selectedImage: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leads.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeadCell", for: indexPath) as! LeadCell
        cell.profileName.text = leads[indexPath.row].name
        cell.username.text = leads[indexPath.row].screenName

        // Fix this
        if let profile = leads[indexPath.row].profileImage {
            var comps = URLComponents(url: profile, resolvingAgainstBaseURL: false)!
            comps.scheme = "https"
            URLSession.shared.dataTask(with: comps.url!, completionHandler: { (data, _, _) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.profilePicture.image = UIImage(data: data)
                    }
                }
            }).resume()
        }

        return cell
    }
}
