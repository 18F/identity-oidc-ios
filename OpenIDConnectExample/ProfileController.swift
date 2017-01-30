//
//  ProfileController.swift
//  OpenIDConnectExample
//
//  Created by Zachary Margolis on 1/31/17.
//  Copyright © 2017 GSA. All rights reserved.
//

import UIKit

class ProfileController : UIViewController {
    var json : Any?

    @IBOutlet weak var textView: UITextView!

    @IBAction func signOut(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
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
