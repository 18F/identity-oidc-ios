//
//  AppDelegate.swift
//  OpenIDConnectExample
//
//  Created by Zachary Margolis on 1/30/17.
//  Copyright © 2017 GSA. All rights reserved.
//

import UIKit
import AppAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var currentAuthorizationSession: OIDAuthorizationFlowSession?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return currentAuthorizationSession!.resumeAuthorizationFlow(with: url);
    }


}

