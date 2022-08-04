//
//  DifficultyViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 29/07/2022.
//

import Epoxy
import UIKit

final class DifficultyViewController: CollectionViewController {
    
    private let triviaViewModel: TriviaViewModel
    
    init(triviaViewModel: TriviaViewModel) {
        self.triviaViewModel = triviaViewModel
        super.init(layout: UICollectionViewCompositionalLayout.list)
        title = "Select Difficulty"
        setItems(items, animated: false)
    }
    
    
    @ItemModelBuilder private var items: [ItemModeling] {
        Difficulty.allCases.map { difficulty in
            TextRow.itemModel(
                dataID: difficulty,
                content: .init(title: difficulty.description(), body: difficulty.description()),
                style: .small)
            .didSelect { [weak self] _ in
                self?.triviaViewModel.onDifficultySelected(difficulty: difficulty)
            }
        }
    }
}
