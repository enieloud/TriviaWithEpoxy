//
//  PaintViewCoordinator.swift
//  WizardPaint2
//
//  Created by Enrique Nieloud on 07/04/2022.
//

import Foundation
import UIKit

class AppCoordinator: NSObject
{
    var window: UIWindow

    init(window: UIWindow) {
        self.window = window
        super.init()
    }

    func start() {
        presentLoadingView()
    }

    func presentLoadingView() {
        window.rootViewController = LoadCategoriesViewController()
        window.makeKeyAndVisible()
    }
}
