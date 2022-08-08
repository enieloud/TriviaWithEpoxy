//
//  RootNavigationController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 27/07/2022.
//

import Epoxy
import RxSwift
import UIKit

final class RootNavigationController: NavigationController {
  let navigationViewModel: NavigationViewModel
  private let disposeBag = DisposeBag()

  init(navigationViewModel: NavigationViewModel) {
    self.navigationViewModel = navigationViewModel
    super.init(wrapNavigation: NavigationWrapperViewController.init(navigationController:))
    self.subscribeToStateChanged()
    setStack(self.stack, animated: false)
  }

  func subscribeToStateChanged() {
    self.navigationViewModel.navigationStatePublisher
      .drive(onNext: { [weak self] _ in
        if let self = self {
          self.setStack(self.stack, animated: true)
        }
      })
      .disposed(by: self.disposeBag)
  }

  @NavigationModelBuilder private var stack: [NavigationModel] {
    NavigationModel.root(dataID: NavigationViewModel.NavigationState.selectingCategory) { [weak self] in
      guard let self = self else { return nil }
      return CategoriesViewController(navigationViewModel: self.navigationViewModel)
    }
    if self.navigationViewModel.navigationState == .selectingDifficulty {
      NavigationModel(
        dataID: NavigationViewModel.NavigationState.selectingDifficulty,
        makeViewController: { [weak self] in
          guard let self = self else { return nil }
          return DifficultyViewController(navigationViewModel: self.navigationViewModel)
        },
        remove: { /* [weak self] in */
          print("selectingDifficulty removed")
        }
      )
    }
    if self.navigationViewModel.navigationState == .selectingQuestionType {
      NavigationModel(
        dataID: NavigationViewModel.NavigationState.selectingQuestionType,
        makeViewController: { [weak self] in
          guard let self = self else { return nil }
          return QuestionTypeViewController(navigationViewModel: self.navigationViewModel)
        },
        remove: { /* [weak self] in */
          print("selectingQuestionType removed")
        }
      )
    }
    if self.navigationViewModel.navigationState == .playing {
      NavigationModel(
        dataID: NavigationViewModel.NavigationState.playing,
        makeViewController: { [weak self] in
          if let self = self {
            return GameViewController(gameViewModel: GameViewModel(
              gameInfo: self.navigationViewModel
                .gameInfo
            ))
          } else { return nil }
        },
        remove: { /* [weak self] in */
          print("playing removed")
        }
      )
    }
  }
}
