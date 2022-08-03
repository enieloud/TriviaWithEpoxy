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
    private var model = TriviaViewModel()
    private let disposeBag = DisposeBag()

    init(window: UIWindow) {
        self.window = window
        super.init()
    }

    func start() {
        subscribeToModel()
        presentLoadingView()
        model.fetchCategories()
    }
    
    func subscribeToModel() {
        model.categories
            .drive(onNext: { categories in
                self.presentRootNavigation(categories: categories) })
            .disposed(by: disposeBag)
    }

    func presentLoadingView() {
        window.rootViewController = LoadCategoriesViewController()
        window.makeKeyAndVisible()
    }
    
    func presentRootNavigation(categories: TriviaCategories) {
        let vc = TriviaNavigationController(viewModel: model, categories: categories)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
}
