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
        readTriviaCategories() { [weak self] categs in
            if let self = self, let categs = categs {
                DispatchQueue.main.async {
                    self.window?.rootViewController = InitialViewController(categories: categs)
                    self.window?.makeKeyAndVisible()
                }
            }
        }
        return true
    }
}

