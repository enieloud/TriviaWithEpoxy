//
//  CategoriesViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 29/07/2022.
//

import Epoxy
import UIKit

/// Source code for `EpoxyCollectionView` "Counter" example from `README.md`:
class CategoriesViewController: CollectionViewController {
    
    private let categories: TriviaCategories
    private let onSelect: ()->Void
    
    init(categories: TriviaCategories, onSelect: @escaping ()->Void) {
        self.onSelect = onSelect
        self.categories = categories
        super.init(layout: UICollectionViewCompositionalLayout.list)
        title = "Select Category"
        setItems(items, animated: false)
    }
    
    private enum DataID {
        case row
    }
    
    private var count = 0 {
        didSet { setItems(items, animated: true) }
    }
    
    @ItemModelBuilder private var items: [ItemModeling] {
        categories.triviaCategories.map { category in
            TextRow.itemModel(
                dataID: category.id,
                content: .init(title: category.name, body: category.name),
                style: .small)
            .didSelect { [weak self] _ in
                self?.onSelect()
                //self?.state.selectDifficulty = DifficultyLevel(difficultyID: 1)
            }
        }
    }
}
