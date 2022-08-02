//
//  QuestionViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 31/07/2022.
//

import Epoxy
import UIKit

final class QuestionViewController: CollectionViewController {
    var game: Game?
    let spinner = UIActivityIndicatorView(style: .large)
    
    private struct AnswerItem {
        var selected: Bool
        var text: String
        var answerID: Int
    }
    
    private struct State {
        let possibleAnswers: [AnswerItem]
        let currentQuestion: String
        let answerChecked: Bool
        let answerSelected: Bool
        let message: String

        func with(message: String)->State {
            State(possibleAnswers: self.possibleAnswers,
                  currentQuestion: self.currentQuestion,
                  answerChecked: self.answerChecked,
                  answerSelected: self.answerSelected,
                  message: message)
        }
    }
    
    private var state: State {
        didSet {
            setItems(items, animated: true)
            topBarInstaller.setBars(topBars, animated: true)
            bottomBarInstaller.setBars(bottomBars, animated: true)
        }
    }
    
    init(gameInfo: GameInfo) {
        let layout = UICollectionViewCompositionalLayout
            .list(using: .init(appearance: .plain))
        state = State(possibleAnswers: [], currentQuestion: "", answerChecked: false, answerSelected: false, message: "")
        super.init(layout: layout)
        startSpinnerView()
        Game.createGame(gameInfo: gameInfo) { game in
            self.stopSpinnerView()
            if let game = game {
                self.game = game
                self.onGameCreated()
            } else {
                self.showText(title: "Error creating game", message: "")
            }
        }
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
        guard let game = game else {
            return
        }
        if game.possibleAnswers.count == 0 {
            showText(title: "Error", message: "\(game.description(short: true))\nbrought no choices!")
        } else {
            topBarInstaller.install()
            bottomBarInstaller.install()
            createStateFromGame(answerChecked: false)
            setItems(items, animated: false)
        }
    }
    
    @ItemModelBuilder
    var items: [ItemModeling] {
        if let game = game {
            if !state.answerChecked {
                state.possibleAnswers.map { answerItem in
                    TextRow.itemModel(
                        dataID: answerItem.answerID,
                        content: .init(title: answerItem.text, body: nil),
                        style: answerItem.selected ? TextRow.Style.large : TextRow.Style.small)
                    .didSelect { [weak self] context in
                        self?.selectItem(id: answerItem.answerID)
                    }
                }
            } else {
                state.possibleAnswers.enumerated().map { (index,answerItem) in
                    TextRow.itemModel(
                        dataID: answerItem.answerID,
                        content: .init(title: answerItem.text, body: nil),
                        style: game.isCorrect(index: index) ? TextRow.Style.large : TextRow.Style.small)
                }
            }
        }
    }
    
    private func createStateFromGame(answerChecked: Bool) {
        guard let game = game else {
            return
        }
        let possibleAnswers = game.possibleAnswers.enumerated().map { (index, possibleAnswer) in
            AnswerItem(selected: false, text: possibleAnswer, answerID: getItemID(position: index))
        }
        state = State(possibleAnswers: possibleAnswers, currentQuestion: game.questionStr, answerChecked: answerChecked, answerSelected: answerChecked, message: "")
    }
    
    private func getItemID(position: Int) -> Int {
        guard let game = game else {
            return 0
        }
        return (game.currentStep+1)*100 + position
    }
    
    private func selectItem(id: Int) {
        if let indexFound = state.possibleAnswers.firstIndex(where: {$0.answerID == id}) {
            let possibleAnswers = state.possibleAnswers.enumerated().map { (idx, item) in
                AnswerItem(
                    selected: idx == indexFound,
                    text: item.text,
                    answerID: item.answerID) }
            self.state = State(possibleAnswers: possibleAnswers, currentQuestion: state.currentQuestion, answerChecked: false, answerSelected: true, message: "")
        }
    }
    
    private func indexOfSelection() -> Int? {
        state.possibleAnswers.firstIndex { item in
            item.selected
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
        Label.barModel(content: state.message, style: Label.Style.style(with: .body, textAlignment: .center))
        if game != nil {
            ButtonRow.barModel(
                content: .init(text: self.state.answerChecked ? "Next Question" : "Check answer!"),
                behaviors: .init(didTap: { self.onBottomButtonTapped() })
            )
        }
    }
    
    func onBottomButtonTapped() {
        if state.answerChecked {
            if game!.isFinihed() {
                state = state.with(message: "Game finished. Your final score is:\(game!.scoreStr)")
            } else {
                game!.next()
                self.createStateFromGame(answerChecked: false)
            }
        } else {
            if !state.answerSelected {
                state = state.with(message: "Please select an answer")
            } else {
                if let indexFound = self.indexOfSelection() {
                    let answerWasCorrect = game!.evalAnswer(index: indexFound)
                    self.createStateFromGame(answerChecked: true)
                    state = state.with(message: answerWasCorrect ? "Correct answer!!!" : "Oops... incorrect answer!!!")
                }
            }
        }
    }
    
    @BarModelBuilder
    var topBars: [BarModeling] {
        if let game = game {
            TextRow.barModel(content: TextRow.Content(title: game.description(), body: game.scoreStr), style: TextRow.Style.small)
            TextRow.barModel(content: TextRow.Content(title: game.currentStepStr, body: state.currentQuestion), style: TextRow.Style.large)
        }
    }
    
    func showText(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
