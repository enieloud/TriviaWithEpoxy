//
//  GameViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 31/07/2022.
//

import Epoxy
import UIKit
import RxCocoa
import RxSwift

final class GameViewController: CollectionViewController {
    let gameViewModel: GameViewModel
    var gameViewState: GameViewModel.GameViewState?
    let spinner = UIActivityIndicatorView(style: .large)
    private let disposeBag = DisposeBag()
    
    init(gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
        let layout = UICollectionViewCompositionalLayout
            .list(using: .init(appearance: .plain))
        super.init(layout: layout)
        subscribeToGameIsCreating()
        subscribeToStateChanged()
        subscribeToShowMessage()
        gameViewModel.createGame()
    }
    
    func subscribeToStateChanged() {
        gameViewModel.gameStatePublisher
            .drive(onNext: { state in
                // TODO: Use [weak self]
                self.gameViewState = state
                self.updateUI()
            })
            .disposed(by: disposeBag)
    }
    
    func updateUI() {
        setItems(items, animated: true)
        topBarInstaller.setBars(topBars, animated: true)
        bottomBarInstaller.setBars(bottomBars, animated: true)
    }
    
    func subscribeToGameIsCreating() {
        gameViewModel.gameIsCreatingPublisher
            .drive(onNext: { isCreating in
                if isCreating {
                    self.startSpinnerView()
                } else {
                    self.stopSpinnerView()
                    self.onGameCreated()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func subscribeToShowMessage() {
        gameViewModel.showMessagePublisher
            .drive(onNext: { message in
                // TODO: Use [weak self]
                self.showText(title: "Error", message: message)
            })
            .disposed(by: disposeBag)
    }
    
    func startSpinnerView() {
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.center = view.center
        spinner.startAnimating()
    }
    
    func stopSpinnerView() {
        self.spinner.stopAnimating()
    }
    
    func onGameCreated() {
        guard let game = gameViewModel.game else {
            return
        }
        if game.possibleAnswers.count > 0 {
            topBarInstaller.install()
            bottomBarInstaller.install()
        }
    }
    
    @ItemModelBuilder
    var items: [ItemModeling] {
        if let game = gameViewModel.game, let gameViewState = self.gameViewState {
            if !gameViewState.answerChecked {
                gameViewState.possibleAnswers.map { answerItem in
                    TextRow.itemModel(
                        dataID: answerItem.answerID,
                        content: .init(title: answerItem.text, body: nil),
                        style: answerItem.selected ? TextRow.Style.large : TextRow.Style.small)
                    .didSelect { [weak self] context in
                        self?.gameViewModel.selectItem(id: answerItem.answerID)
                    }
                }
            } else {
                gameViewState.possibleAnswers.enumerated().map { (index,answerItem) in
                    TextRow.itemModel(
                        dataID: answerItem.answerID,
                        content: .init(title: answerItem.text, body: nil),
                        style: game.isCorrect(index: index) ? TextRow.Style.green : TextRow.Style.red)
                }
            }
        }
    }
    
    lazy var topBarInstaller = TopBarInstaller(
        viewController: self,
        bars: topBars)
    lazy var bottomBarInstaller = BottomBarInstaller(
        viewController: self,
        bars: bottomBars)
    
    @BarModelBuilder
    var bottomBars: [BarModeling] {
        if let gameViewState = self.gameViewState {
            Label.barModel(content: gameViewState.message, style: .style(with: .body, textAlignment: .center, color: .black))
        }
        if let game = gameViewModel.game {
            if !game.isFinihed() {
                ButtonRow.barModel(
                    content: .init(text: gameViewModel.getButtonText(game: game) ),
                    behaviors: .init(didTap: { self.gameViewModel.onBottomButtonTapped() })
                )
            } else {
                TextRow.barModel(content: TextRow.Content(title: nil, body: gameViewModel.getButtonText(game: game)),
                                 style: .large)
            }
        }
    }
    
    @BarModelBuilder
    var topBars: [BarModeling] {
        if let game = gameViewModel.game, let gameViewState = self.gameViewState {
            TextRow.barModel(content: TextRow.Content(title: game.description(), body: game.scoreStr), style: TextRow.Style.small)
            TextRow.barModel(content: TextRow.Content(title: game.currentStepStr, body: gameViewState.currentQuestion), style: TextRow.Style.large)
        }
    }
    
    func showText(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
