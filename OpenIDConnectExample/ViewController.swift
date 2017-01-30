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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func didSelectLoginGov(_ sender: Any) {
        let delegate = UIApplication.shared.delegate! as! AppDelegate

        delegate.currentAuthorizationSession = OIDAuthorizationService.present(LoginGovService.authorizationRequest(), presenting: self, callback: { (response: OIDAuthorizationResponse?, error: Error?) in

            if let authorizationCode = response?.authorizationCode {
                let tokenRequest = LoginGovService.tokenRequest(authorizationCode: authorizationCode)
                OIDAuthorizationService.perform(tokenRequest, callback: { (response: OIDTokenResponse?, error: Error?) in
                    print(response)
                })
            }
        })
    }

}

