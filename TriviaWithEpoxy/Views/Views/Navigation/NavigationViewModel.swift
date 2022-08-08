//
//  TriviaViewModel.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 03/08/2022.
//

import Foundation
import RxCocoa
import RxSwift

final class NavigationViewModel {
  enum NavigationState: Hashable {
    case selectingCategory
    case selectingDifficulty
    case selectingQuestionType
    case playing
  }

  var navigationState: NavigationState = .selectingCategory
  private var navigationStateSubject = PublishSubject<NavigationState>()
  lazy var navigationStatePublisher = navigationStateSubject
    .asDriver(onErrorJustReturn: NavigationState.selectingCategory)
  var gameInfo: GameInfo

  var categories: TriviaCategories {
    self.gameInfo.categories
  }

  init(gameInfo: GameInfo) {
    self.gameInfo = gameInfo
  }

  func onCategorySelected(categoryId: Int) {
    self.gameInfo.categoryId = categoryId
    self.navigationState = .selectingDifficulty
    self.navigationStateSubject.onNext(self.navigationState)
  }

  func onQuestionTypeSelected(questionType: QuestionType) {
    self.gameInfo.type = questionType
    self.gameInfo.amount = 5
    self.navigationState = .playing
    self.navigationStateSubject.onNext(self.navigationState)
  }

  func onDifficultySelected(difficulty: Difficulty) {
    self.gameInfo.difficulty = difficulty
    self.navigationState = .selectingQuestionType
    self.navigationStateSubject.onNext(self.navigationState)
  }
}
