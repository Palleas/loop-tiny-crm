//
//  AppDelegate.swift
//  Loop
//
//  Created by Romain Pouclet on 2017-06-21.
//  Copyright © 2017 Perfectly-Cooked. All rights reserved.
//

import UIKit
import LoopKit
import KeychainSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let coordinator = AppCoordinator(
        consumerKey: ProcessInfo.processInfo.environment["TWITTER_CONSUMER_KEY"]!,
        consumerSecret: ProcessInfo.processInfo.environment["TWITTER_CONSUMER_SECRET"]!
    )

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BuddyBuildSDK.setup()

        let window = UIWindow()
        window.rootViewController = coordinator.controller
        window.makeKeyAndVisible()
        self.window = window

        coordinator.start()

        // Setup Appearances
        UINavigationBar.appearance().backgroundColor = .white
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = UIColor(named: "grapeFruit")!

        let attributes: [NSAttributedStringKey : Any] = [
            .font: FontFamily.SourceSansPro.regular.font(size: 17)
        ]
        UINavigationBar.appearance().titleTextAttributes = attributes

        UIBarButtonItem.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor(named: "grapeFruit")!
        ], for: .normal)

        UITabBar.appearance().tintColor = ColorName.grapefruit.color
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().unselectedItemTintColor = ColorName.coolGrey.color
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()

        return true
    }
}

