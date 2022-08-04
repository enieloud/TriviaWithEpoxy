//
//  TriviaViewModel.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 03/08/2022.
//

import Foundation
import RxSwift
import RxCocoa

final class NavigationViewModel {
    enum NavigationState: Hashable {
        case selectingCategory
        case selectingDifficulty
        case selectingQuestionType
        case playing
    }
    
    var navigationState: NavigationState = NavigationState.selectingCategory
    private var navigationStateSubject = PublishSubject<NavigationState>()
    lazy var navigationStatePublisher = navigationStateSubject.asDriver(onErrorJustReturn: NavigationState.selectingCategory)
    var gameInfo: GameInfo

    var categories: TriviaCategories {
        get {
            gameInfo.categories
        }
    }
    
    init(gameInfo: GameInfo) {
        self.gameInfo = gameInfo
    }

    func onCategorySelected(categoryId: Int) {
        gameInfo.categoryId = categoryId
        navigationState = .selectingDifficulty
        navigationStateSubject.onNext(navigationState)
    }

    func onQuestionTypeSelected(questionType: QuestionType) {
        gameInfo.type = questionType
        gameInfo.amount = 5
        navigationState = .playing
        navigationStateSubject.onNext(navigationState)
    }
    
    func onDifficultySelected(difficulty: Difficulty) {
        gameInfo.difficulty = difficulty
        navigationState = .selectingQuestionType
        navigationStateSubject.onNext(navigationState)
    }
}
