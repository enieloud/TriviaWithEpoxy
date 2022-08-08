//
//  QuestionTypeViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 30/07/2022.
//

import Epoxy
import UIKit

final class QuestionTypeViewController: CollectionViewController {
  private let navigationViewModel: NavigationViewModel

  init(navigationViewModel: NavigationViewModel) {
    self.navigationViewModel = navigationViewModel
    super.init(layout: UICollectionViewCompositionalLayout.list)
    title = "Select Question type"
    setItems(self.items, animated: false)
  }

  @ItemModelBuilder private var items: [ItemModeling] {
    QuestionType.allCases.map { questionType in
      TextRow.itemModel(
        dataID: questionType,
        content: .init(title: questionType.description(), body: questionType.description()),
        style: .small
      )
      .didSelect { [weak self] _ in
        self?.navigationViewModel.onQuestionTypeSelected(questionType: questionType)
      }
    }
  }
}
