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
    private var triviaViewModel = TriviaViewModel()
    private let disposeBag = DisposeBag()

    init(window: UIWindow) {
        self.window = window
        super.init()
    }

    func start() {
        subscribeToModel()
        triviaViewModel.fetchCategories()
    }
    
    func subscribeToModel() {
        triviaViewModel.categoriesIsLoadingPublisher
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
        window.rootViewController = LoadCategoriesViewController()
        window.makeKeyAndVisible()
    }
    
    func presentRootNavigation() {
        let vc = TriviaNavigationController(viewModel: triviaViewModel)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
}
