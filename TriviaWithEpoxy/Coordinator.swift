//
//  PaintViewCoordinator.swift
//  WizardPaint2
//
//  Created by Enrique Nieloud on 07/04/2022.
//

import RxSwift
import UIKit

class AppCoordinator: NSObject
{
    private var window: UIWindow
    private var categoriesViewModel = CategoriesViewModel()
    private let disposeBag = DisposeBag()

    init(window: UIWindow) {
        self.window = window
        super.init()
    }

    func start() {
        subscribeToModel()
        categoriesViewModel.fetchCategories()
    }
    
    func subscribeToModel() {
        categoriesViewModel.categoriesIsLoadingPublisher
            .drive(onNext: { isLoading in
                if isLoading {
                    self.presentLoadingView()
                } else {
                    self.presentRootNavigation()
                }
                 })
            .disposed(by: disposeBag)
    }

    func presentLoadingView() {
        window.rootViewController = SpinnerViewController()
        window.makeKeyAndVisible()
    }
    
    func presentRootNavigation() {
        let vc = RootNavigationController(navigationViewModel: NavigationViewModel(gameInfo:categoriesViewModel.gameInfo!))
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
}
