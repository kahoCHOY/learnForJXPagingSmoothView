//
//  AppDelegate.swift
//  JXPagingSmoothView_Demo
//
//  Created by 家濠 on 2022/1/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        window = UIWindow()
        let navi = UINavigationController(rootViewController: ViewController())
        window?.rootViewController = navi
        window?.makeKeyAndVisible()
        
        
        
        
        return true
    }


}

