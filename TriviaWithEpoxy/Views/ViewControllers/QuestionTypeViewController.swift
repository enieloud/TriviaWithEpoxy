//
//  QuestionTypeViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 30/07/2022.
//

import Epoxy
import UIKit

final class QuestionTypeViewController: CollectionViewController {
    
    private let triviaViewModel: TriviaViewModel
    
    init(triviaViewModel: TriviaViewModel) {
        self.triviaViewModel = triviaViewModel
        super.init(layout: UICollectionViewCompositionalLayout.list)
        title = "Select Question type"
        setItems(items, animated: false)
    }
    
    @ItemModelBuilder private var items: [ItemModeling] {
        QuestionType.allCases.map { questionType in
            TextRow.itemModel(
                dataID: questionType,
                content: .init(title: questionType.description(), body: questionType.description()),
                style: .small)
            .didSelect { [weak self] _ in
                self?.triviaViewModel.onQuestionTypeSelected(questionType: questionType)
            }
        }
    }
}
