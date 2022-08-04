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
        presentLoadingView()
        triviaViewModel.fetchCategories()
    }
    
    func subscribeToModel() {
        triviaViewModel.categoriesPublisher
            .drive(onNext: { categories in
                self.triviaViewModel.gameInfo = GameInfo(categories: categories)
                self.presentRootNavigation() })
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
