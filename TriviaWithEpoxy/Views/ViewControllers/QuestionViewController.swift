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
        
        func with(possibleAnswers: [AnswerItem])->State {
            State(possibleAnswers: possibleAnswers,
                  currentQuestion: self.currentQuestion,
                  answerChecked: self.answerChecked,
                  answerSelected: self.answerSelected,
                  message: self.message)
        }
        
        func with(currentQuestion: String)->State {
            State(possibleAnswers: self.possibleAnswers,
                  currentQuestion: currentQuestion,
                  answerChecked: self.answerChecked,
                  answerSelected: self.answerSelected,
                  message: self.message)
        }
        
        func with(answerChecked: Bool)->State {
            State(possibleAnswers: self.possibleAnswers,
                  currentQuestion: self.currentQuestion,
                  answerChecked: answerChecked,
                  answerSelected: self.answerSelected,
                  message: self.message)
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
            state = State(possibleAnswers: mapPossibleAnswers(from: game),
                          currentQuestion: game.questionStr,
                          answerChecked: false,
                          answerSelected: false,
                          message: "")
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
    
    private func mapPossibleAnswers(from game: Game) -> [AnswerItem] {
        return game.possibleAnswers.enumerated().map { (index, possibleAnswer) in
            AnswerItem(selected: false, text: possibleAnswer, answerID: getItemID(position: index))
        }
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
        Label.barModel(content: state.message, style: .style(with: .body, textAlignment: .center))
        if let game = game {
            if !game.isFinihed() {
                ButtonRow.barModel(
                    content: .init(text: getButtonText(game: game) ),
                    behaviors: .init(didTap: { self.onBottomButtonTapped() })
                )
            } else {
                TextRow.barModel(content: TextRow.Content(title: nil, body: getButtonText(game: game)),
                                 style: .large)
            }
        }
    }
    
    func getButtonText(game: Game)->String {
        if game.isFinihed() {
            if state.answerChecked {
                return "Game finished. Your final score is:\(game.scoreStr)"
            } else {
                return "Check answer!"
            }
        } else {
            if state.answerChecked {
                return "Next Question"
            } else {
                return "Check answer!"
            }

        }
    }

    func onBottomButtonTapped() {
        if game == nil {
            return
        }
        var message = ""
        var answerChecked = false
        if state.answerChecked {
            if !game!.isFinihed() {
                game!.next()
            }
        } else {
            if !state.answerSelected {
                message = "Please select an answer"
            } else {
                if let indexFound = self.indexOfSelection() {
                    let answerWasCorrect = game!.evalAnswer(index: indexFound)
                    answerChecked = true
                    message = answerWasCorrect ? "Correct answer!!!" : "Oops... incorrect answer!!!"
                }
            }
        }
        // update the state
        state = state
            .with(possibleAnswers: mapPossibleAnswers(from: game!))
            .with(currentQuestion: game!.questionStr)
            .with(message: message)
            .with(answerChecked: answerChecked)
        
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
