//
//  GameViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 31/07/2022.
//

import Epoxy
import RxCocoa
import RxSwift
import UIKit

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
    self.subscribeToGameIsCreating()
    self.subscribeToStateChanged()
    self.subscribeToShowMessage()
    gameViewModel.createGame()
  }

  func subscribeToStateChanged() {
    self.gameViewModel.gameStatePublisher
      .drive(onNext: { [weak self] state in
        self?.gameViewState = state
        self?.updateUI()
      })
      .disposed(by: self.disposeBag)
  }

  func updateUI() {
    setItems(self.items, animated: true)
    self.topBarInstaller.setBars(self.topBars, animated: true)
    self.bottomBarInstaller.setBars(self.bottomBars, animated: true)
  }

  func subscribeToGameIsCreating() {
    self.gameViewModel.gameIsCreatingPublisher
      .drive(onNext: { [weak self] isCreating in
        if isCreating {
          self?.startSpinnerView()
        } else {
          self?.stopSpinnerView()
          self?.onGameCreated()
        }
      })
      .disposed(by: self.disposeBag)
  }

  func subscribeToShowMessage() {
    self.gameViewModel.showMessagePublisher
      .drive(onNext: { [weak self] message in
        self?.showText(title: "Error", message: message)
      })
      .disposed(by: self.disposeBag)
  }

  func startSpinnerView() {
    self.spinner.hidesWhenStopped = true
    view.addSubview(self.spinner)
    self.spinner.center = view.center
    self.spinner.startAnimating()
  }

  func stopSpinnerView() {
    self.spinner.stopAnimating()
  }

  func onGameCreated() {
    guard let game = gameViewModel.game else {
      return
    }
    if !game.possibleAnswers.isEmpty {
      self.topBarInstaller.install()
      self.bottomBarInstaller.install()
    }
  }

  @ItemModelBuilder var items: [ItemModeling] {
    if let gameViewState = self.gameViewState {
      gameViewState.possibleAnswers.map { answerItem in
        TextRow.itemModel(
          dataID: answerItem.answerID,
          content: .init(title: answerItem.text, body: nil),
          style: answerItem.style.toRowStyle()
        )
        .didSelect { [weak self] _ in
          if answerItem.enabled {
            self?.gameViewModel.selectItem(id: answerItem.answerID)
          }
        }
      }
    }
  }

  lazy var topBarInstaller = TopBarInstaller(
    viewController: self,
    bars: topBars
  )
  lazy var bottomBarInstaller = BottomBarInstaller(
    viewController: self,
    bars: bottomBars
  )

  @BarModelBuilder var bottomBars: [BarModeling] {
    if let gameViewState = gameViewState {
      Label.barModel(
        content: gameViewState.message,
        style: .style(with: .body, textAlignment: .center, color: .black)
      )
    }
    if let game = gameViewModel.game {
      if !game.isFinihed() {
        ButtonRow.barModel(
          dataID: "BOTTOM_INFO_BAR",
          content: .init(text: self.gameViewModel.getButtonText(game: game)),
          behaviors: .init(didTap: { self.gameViewModel.onBottomButtonTapped() })
        )
      } else {
        TextRow.barModel(
          dataID: "BOTTOM_FINIDHED_BAR",
          content: TextRow.Content(title: nil, body: self.gameViewModel.getButtonText(game: game)),
          style: .large
        )
      }
    }
  }

  @BarModelBuilder var topBars: [BarModeling] {
    if let game = gameViewModel.game, let gameViewState = gameViewState {
      TextRow.barModel(
        dataID: "GAME_DESCRIPTION_BAR",
        content: TextRow.Content(title: game.description(), body: game.scoreStr),
        style: TextRow.Style.small
      )
      TextRow.barModel(
        dataID: "GAME_QUESTION_BAR",
        content: TextRow.Content(title: game.currentStepStr, body: gameViewState.currentQuestion),
        style: TextRow.Style.large
      )
    }
  }

  func showText(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
}
