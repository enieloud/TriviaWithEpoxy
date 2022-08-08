//
//  PaintViewCoordinator.swift
//  WizardPaint2
//
//  Created by Enrique Nieloud on 07/04/2022.
//

import RxSwift
import UIKit

class AppCoordinator: NSObject {
  private var window: UIWindow
  private var categoriesViewModel = CategoriesViewModel()
  private let disposeBag = DisposeBag()

  init(window: UIWindow) {
    self.window = window
    super.init()
  }

  func start() {
    self.subscribeToModel()
    self.categoriesViewModel.fetchCategories()
  }

  func subscribeToModel() {
    self.categoriesViewModel.categoriesIsLoadingPublisher
      .drive(onNext: { isLoading in
        if isLoading {
          self.presentLoadingView()
        } else {
          self.presentRootNavigation()
        }
      })
      .disposed(by: self.disposeBag)
  }

  func presentLoadingView() {
    self.window.rootViewController = SpinnerViewController()
    self.window.makeKeyAndVisible()
  }

  func presentRootNavigation() {
    let rootNavigationController = RootNavigationController(
      navigationViewModel: NavigationViewModel(gameInfo: categoriesViewModel.gameInfo!)
    )
    self.window.rootViewController = rootNavigationController
    self.window.makeKeyAndVisible()
  }
}
