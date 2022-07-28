//
//  InitialViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 27/07/2022.
//

import UIKit
import Epoxy

let categories = ["General Knowledge", "Entertainment: Books", "Entertainment: Films"]

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
    
    init() {
        super.init(wrapNavigation: NavigationWrapperViewController.init(navigationController:))
        setStack(stack, animated: false)
    }
    
    @NavigationModelBuilder private var stack: [NavigationModel] {
        NavigationModel.root(dataID: DataID.category) { [weak self] in
            self?.createCategoriesViewController()
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
    
    private func createCategoriesViewController() -> UIViewController {
        let viewController = CollectionViewController(
            layout: UICollectionViewCompositionalLayout.list,
            items: {
                categories.map { category in
                    TextRow.itemModel(
                        dataID: category,
                        content: .init(title: category, body: category),
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
