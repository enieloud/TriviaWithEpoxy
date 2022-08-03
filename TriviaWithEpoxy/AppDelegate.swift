//
//  AppDelegate.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 27/07/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let coordinator = AppCoordinator(window: window!)
        coordinator.start()
        return true
    }
}
