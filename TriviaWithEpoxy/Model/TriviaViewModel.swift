//
//  TriviaViewModel.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 03/08/2022.
//

import Foundation
import RxSwift
import RxCocoa

final class TriviaViewModel {
    private let disposeBag = DisposeBag()
    var gameInfo: GameInfo?
// MARK: - Categories
    private var categoriesIsLoadingSubject = PublishSubject<Bool>()
    lazy var categoriesIsLoadingPublisher = categoriesIsLoadingSubject.asDriver(onErrorJustReturn: false)

    func fetchCategories() {
        self.categoriesIsLoadingSubject.onNext(true)
        TriviaAPIClient.fetchCategories()
            .subscribe(onNext: { categories in
                self.gameInfo = GameInfo(categories: categories)
                self.categoriesIsLoadingSubject.onNext(false)
            },
        onError: { error in
            })
        .disposed(by: disposeBag)
    }
    
    // MARK: - Game
    private var gameSubject = PublishSubject<Game>()
    lazy var gamePublisher = gameSubject.asDriver(onErrorJustReturn: Game.empty())

    func createGame() {
        guard let gameInfo = gameInfo else { return }
        TriviaAPIClient.newGame(gameInfo: gameInfo)
            .subscribe(onNext: { game in
                self.gameSubject.onNext(game)
            },
        onError: { error in
            })
        .disposed(by: disposeBag)
    }

// MARK: - Navigation State
    enum NavigationState: Hashable {
        case selectingCategory
        case selectingDifficulty
        case selectingQuestionType
        case playing
    }
    
    var navigationState: NavigationState = NavigationState.selectingCategory
    private var navigationStateSubject = PublishSubject<NavigationState>()
    lazy var navigationStatePublisher = navigationStateSubject.asDriver(onErrorJustReturn: NavigationState.selectingCategory)

    func onCategorySelected(categoryId: Int) {
        gameInfo?.categoryId = categoryId
        navigationState = .selectingDifficulty
        navigationStateSubject.onNext(navigationState)
    }

    func onQuestionTypeSelected(questionType: QuestionType) {
        gameInfo?.type = questionType
        gameInfo?.amount = 5
        navigationState = .playing
        navigationStateSubject.onNext(navigationState)
    }
    
    func onDifficultySelected(difficulty: Difficulty) {
        gameInfo?.difficulty = difficulty
        navigationState = .selectingQuestionType
        navigationStateSubject.onNext(navigationState)
    }
}
