//
//  AppDelegate.swift
//  Wundercast_MVVM
//
//  Created by yfm on 2022/10/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        let vc = WeatherViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        return true
    }
}

