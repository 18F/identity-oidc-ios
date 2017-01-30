//
//  ViewController.swift
//  OpenIDConnectExample
//
//  Created by Zachary Margolis on 1/30/17.
//  Copyright © 2017 GSA. All rights reserved.
//

import UIKit
import AppAuth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didSelectLoginGov(_ sender: Any) {
        let delegate = UIApplication.shared.delegate! as! AppDelegate

        delegate.currentAuthorizationSession = OIDAuthorizationService.present(LoginGovService.authorizationRequest(), presenting: self, callback: { (response: OIDAuthorizationResponse?, error: Error?) in
        })
    }

}

