//
//  InitialViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 27/07/2022.
//

import UIKit
import Epoxy

final class InitialViewController: NavigationController {
    
    var categories: TriviaCategories
    
    private enum NavPage: Hashable {
        case selectingCategory
        case selectingDifficulty
        case selectingQuestionType
        case playing
    }
    
    private struct State {
        var gameInfo: GameInfo
        var page = NavPage.selectingCategory
    }
    
    private var state: State {
        didSet {
            setStack(stack, animated: true)
        }
    }
    
    init(categories: TriviaCategories) {
        self.categories = categories
        self.state = State(gameInfo: GameInfo(categories: categories))
        super.init(wrapNavigation: NavigationWrapperViewController.init(navigationController:))
        self.setStack(self.stack, animated: false)
    }
    
    @NavigationModelBuilder private var stack: [NavigationModel] {
        NavigationModel.root(dataID: NavPage.selectingCategory) { [weak self] in
            guard let self = self else { return nil }
            return self.createCategoriesViewController()
        }
        if state.page == .selectingDifficulty {
            NavigationModel(
                dataID: NavPage.selectingDifficulty,
                makeViewController: { [weak self] in
                    self?.createSelectDifficulty()
                },
                remove: { [weak self] in
                    print("remove de selectingDifficulty")
                })
        }
        if state.page == .selectingQuestionType {
            NavigationModel(
                dataID: NavPage.selectingQuestionType,
                makeViewController: { [weak self] in
                    self?.createSelectQuestionType()
                },
                remove: { [weak self] in
                    print("remove de selectingQuestionType")
                })
        }
        if state.page == .playing {
            NavigationModel(
                dataID: NavPage.playing,
                makeViewController: { [weak self] in
                    if let self = self {
                        return QuestionViewController(gameInfo: self.state.gameInfo)
                    } else { return nil }
                },
                remove: { [weak self] in
                    print("remove de playing")
                })
        }
    }
    
    private func createCategoriesViewController() -> UIViewController {
        return CategoriesViewController(categories: categories) { [weak self] categoryId in
            if let self = self {
                var newState = self.state
                newState.gameInfo.categoryId = categoryId
                newState.page = .selectingDifficulty
                self.state = newState
            }
        }
    }
    
    private func createSelectQuestionType() -> UIViewController {
        return QuestionTypeViewController() { [weak self] questionType in
            if let self = self {
                var newGameInfo = self.state.gameInfo
                newGameInfo.type = questionType
                newGameInfo.amount = 10
                var newState = self.state
                newState.page = .playing
                newState.gameInfo = newGameInfo
                self.state = newState
            }
        }
    }
    
    private func createSelectDifficulty() -> UIViewController {
        return DifficultyViewController() { [weak self] difficulty in
            if let self = self {
                var newState = self.state
                newState.gameInfo.difficulty = difficulty
                newState.page = .selectingQuestionType
                self.state = newState
            }
        }
    }
}
