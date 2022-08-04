//
//  CategoriesViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 29/07/2022.
//

import Epoxy
import UIKit

/// Source code for `EpoxyCollectionView` "Counter" example from `README.md`:
final class CategoriesViewController: CollectionViewController {
    
    private let navigationViewModel: NavigationViewModel
    
    init(navigationViewModel: NavigationViewModel) {
        self.navigationViewModel = navigationViewModel
        super.init(layout: UICollectionViewCompositionalLayout.list)
        title = "Select Category"
        setItems(items, animated: false)
    }
    
    @ItemModelBuilder private var items: [ItemModeling] {
        navigationViewModel.categories.triviaCategories.map { category in
            TextRow.itemModel(
                dataID: category.id,
                content: .init(title: category.name, body: category.name),
                style: .small)
            .didSelect { [weak self] _ in
                self?.navigationViewModel.onCategorySelected(categoryId: category.id)
            }
        }
    }
}