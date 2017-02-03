import UIKit

class ProfileController : UIViewController {
    var json : Any?

    @IBOutlet weak var textView: UITextView!

    @IBAction func signOut(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        if let json = json {
            updateProfile(json: json)
        }
    }

    public func updateProfile(json : Any) {
        self.json = json

        let profile : [ String : Any ] = json as! Dictionary

        let parts = profile.map { (key: String, value: Any) in
            return "\(key) = \(value)"
        }

        self.textView?.text = parts.joined(separator: "\n")
    }
}
