//
//  InitialViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 27/07/2022.
//

import UIKit
import Epoxy

struct DifficultyLevel: Hashable {
    static let list = ["Easy", "Medium", "Hard"]
    var difficultyID: Int
    var text: String {
        get {
            switch difficultyID {
            case 1: return "Easy"
            case 2: return "Medium"
            case 3: return "Hard"
            default: return "Easy"
            }
        }
    }
}

class InitialViewController: NavigationController {
    private let categories: TriviaCategories
    
    private enum DataID: Hashable {
        case category
        case difficulty(DifficultyLevel)
    }
    
    private struct State {
        var selectDifficulty: DifficultyLevel?
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
            self?.createCategoriesViewController(categories: self!.categories)
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
        let viewController = CollectionViewController(
            layout: UICollectionViewCompositionalLayout.list,
            items: {
                categories.triviaCategories.map { category in
                    TextRow.itemModel(
                        dataID: category.id,
                        content: .init(title: category.name, body: category.name),
                        style: .small)
                    .didSelect { [weak self] _ in
                        self?.state.selectDifficulty = DifficultyLevel(difficultyID: 1)
                    }
                }
            })
        viewController.title = "Select Category"
        return viewController
    }
    
    private func createSelectDifficulty() -> UIViewController {
        let viewController = CollectionViewController(
            layout: UICollectionViewCompositionalLayout.list,
            items: {
                DifficultyLevel.list.map { d in
                    TextRow.itemModel(
                        dataID: d,
                        content: .init(title: d, body: d),
                        style: .small)
                    .didSelect { [weak self] _ in
                        //self?.state.showExample = example
                    }
                }
            })
        viewController.title = "Select Category"
        return viewController
    }
}
