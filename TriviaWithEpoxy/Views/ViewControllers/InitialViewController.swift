//
//  InitialViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 27/07/2022.
//

import UIKit
import Epoxy

class InitialViewController: NavigationController {
    private let categories: TriviaCategories
    
    private enum DataID: Hashable {
        case category
        case difficulty(Difficulty)
    }
    
    private struct State {
        var selectDifficulty: Difficulty?
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
        NavigationModel.root(dataID: DataID.category) { [weak self] in
            guard let self = self else { return nil }
            return self.createCategoriesViewController(categories: self.categories)
        }
        if let selectDifficulty = state.selectDifficulty {
            NavigationModel(
                dataID: DataID.difficulty(selectDifficulty),
                makeViewController: { [weak self] in
                    self?.createSelectDifficulty()
                },
                remove: { [weak self] in
                    self?.state.selectDifficulty = nil
                })
        }
    }
    
    private func createCategoriesViewController(categories: TriviaCategories) -> UIViewController {
        return CategoriesViewController(categories: categories) { [weak self] in
            self?.state.selectDifficulty = Difficulty.easy
        }
    }
    
    private func createSelectDifficulty() -> UIViewController {
        return DifficultyViewController() { /* empty block */ }
    }
}
