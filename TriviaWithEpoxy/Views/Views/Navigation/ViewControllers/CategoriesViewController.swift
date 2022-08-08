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
    setItems(self.items, animated: false)
  }

  @ItemModelBuilder private var items: [ItemModeling] {
    self.navigationViewModel.categories.triviaCategories.map { category in
      SwiftUITextRow(title: category.nameWithoutGroup, subtitle: category.group, icons: category.possibleIcons)
        // swiftlint:disable:next no_direct_standard_out_logs
        .onAppear { print("Row \(category.id) appeared") }
        // swiftlint:disable:next no_direct_standard_out_logs
        .onDisappear { print("Row \(category.id) disappeared") }
        .itemModel(dataID: category.id)
        .didSelect { [weak self] _ in
          self?.navigationViewModel.onCategorySelected(categoryId: category.id)
        }
    }
  }
}
