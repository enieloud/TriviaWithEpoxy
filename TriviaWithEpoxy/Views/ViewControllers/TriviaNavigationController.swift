//
//  InitialViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 27/07/2022.
//

import UIKit
import Epoxy
import RxSwift

final class TriviaNavigationController: NavigationController {
    
    let viewModel: TriviaViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: TriviaViewModel) {
        self.viewModel = viewModel
        super.init(wrapNavigation: NavigationWrapperViewController.init(navigationController:))
        subscribeToStateChanged()
        self.setStack(self.stack, animated: false)
    }
    
    func subscribeToStateChanged() {
        viewModel.navigationStatePublisher
            .drive(onNext: { navigationState in
                //TODO: Make [weak self]
                self.setStack(self.stack, animated: true) })
            .disposed(by: disposeBag)
    }
    
    @NavigationModelBuilder private var stack: [NavigationModel] {
        NavigationModel.root(dataID: TriviaViewModel.NavigationState.selectingCategory) { [weak self] in
            guard let self = self else { return nil }
            return CategoriesViewController(triviaViewModel: self.viewModel)
        }
        if viewModel.navigationState == .selectingDifficulty {
            NavigationModel(
                dataID: TriviaViewModel.NavigationState.selectingDifficulty,
                makeViewController: { [weak self] in
                    guard let self = self else { return nil }
                    return DifficultyViewController(triviaViewModel: self.viewModel)
                },
                remove: { [weak self] in
                    print("remove de selectingDifficulty")
                })
        }
        if viewModel.navigationState == .selectingQuestionType {
            NavigationModel(
                dataID: TriviaViewModel.NavigationState.selectingQuestionType,
                makeViewController: { [weak self] in
                    guard let self = self else { return nil }
                    return QuestionTypeViewController(triviaViewModel: self.viewModel)
                },
                remove: { [weak self] in
                    print("remove de selectingQuestionType")
                })
        }
        if viewModel.navigationState == .playing {
            NavigationModel(
                dataID: TriviaViewModel.NavigationState.playing,
                makeViewController: { [weak self] in
                    if let self = self {
                        return QuestionViewController(triviaViewModel: self.viewModel)
                    } else { return nil }
                },
                remove: { [weak self] in
                    print("remove de playing")
                })
        }
    }
}
