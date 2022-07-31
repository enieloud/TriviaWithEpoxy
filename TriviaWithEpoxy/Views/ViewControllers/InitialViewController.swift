//
//  InitialViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 27/07/2022.
//

import UIKit
import Epoxy

class InitialViewController: NavigationController {
    
    var categories: TriviaCategories
    
    private enum NavPage: Hashable {
        case selectingCategory
        case selectingDifficulty//(Difficulty)
        case selectingQuestionType//(QuestionType)
        case playing
    }
    
    private struct State {
        var difficulty: Difficulty?
        var type: QuestionType?
        var page = NavPage.selectingCategory
    }
    
    private var state = State() {
        didSet {
            setStack(stack, animated: true)
        }
    }
    
    init(categories: TriviaCategories) {
        self.categories = categories
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
    }
    
    private func createCategoriesViewController() -> UIViewController {
        return CategoriesViewController(categories: categories) { [weak self] categoryId in
            if let self = self {
                var newState = self.state
                self.categories.currentCategoryId = categoryId
                newState.page = .selectingDifficulty
                self.state = newState
            }
        }
    }
    
    private func createSelectQuestionType() -> UIViewController {
        return QuestionTypeViewController() { [weak self] questionType in
            if let self = self {
                var newState = self.state
                newState.type = questionType
                newState.page = .playing
                self.state = newState
            }
        }
    }
    
    private func createSelectDifficulty() -> UIViewController {
        return DifficultyViewController() { [weak self] difficulty in
            if let self = self {
                var newState = self.state
                newState.difficulty = difficulty
                newState.page = .selectingQuestionType
                self.state = newState
            }
        }
    }
}
