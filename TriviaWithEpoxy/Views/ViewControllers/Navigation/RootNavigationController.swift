//
//  RootNavigationController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 27/07/2022.
//

import UIKit
import Epoxy
import RxSwift

final class RootNavigationController: NavigationController {
    
    let navigationViewModel: NavigationViewModel
    private let disposeBag = DisposeBag()

    init(navigationViewModel: NavigationViewModel) {
        self.navigationViewModel = navigationViewModel
        super.init(wrapNavigation: NavigationWrapperViewController.init(navigationController:))
        subscribeToStateChanged()
        self.setStack(self.stack, animated: false)
    }
    
    func subscribeToStateChanged() {
        navigationViewModel.navigationStatePublisher
            .drive(onNext: { navigationState in
                //TODO: Make [weak self]
                self.setStack(self.stack, animated: true) })
            .disposed(by: disposeBag)
    }
    
    @NavigationModelBuilder private var stack: [NavigationModel] {
        NavigationModel.root(dataID: NavigationViewModel.NavigationState.selectingCategory) { [weak self] in
            guard let self = self else { return nil }
            return CategoriesViewController(navigationViewModel: self.navigationViewModel)
        }
        if navigationViewModel.navigationState == .selectingDifficulty {
            NavigationModel(
                dataID: NavigationViewModel.NavigationState.selectingDifficulty,
                makeViewController: { [weak self] in
                    guard let self = self else { return nil }
                    return DifficultyViewController(navigationViewModel: self.navigationViewModel)
                },
                remove: { [weak self] in
                    print("remove de selectingDifficulty")
                })
        }
        if navigationViewModel.navigationState == .selectingQuestionType {
            NavigationModel(
                dataID: NavigationViewModel.NavigationState.selectingQuestionType,
                makeViewController: { [weak self] in
                    guard let self = self else { return nil }
                    return QuestionTypeViewController(navigationViewModel: self.navigationViewModel)
                },
                remove: { [weak self] in
                    print("remove de selectingQuestionType")
                })
        }
        if navigationViewModel.navigationState == .playing {
            NavigationModel(
                dataID: NavigationViewModel.NavigationState.playing,
                makeViewController: { [weak self] in
                    if let self = self {
                        return QuestionViewController(gameViewModel: GameViewModel(gameInfo: self.navigationViewModel.gameInfo))
                    } else { return nil }
                },
                remove: { [weak self] in
                    print("remove de playing")
                })
        }
    }
}
