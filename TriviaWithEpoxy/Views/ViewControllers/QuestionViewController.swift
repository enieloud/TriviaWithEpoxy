//
//  QuestionViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 31/07/2022.
//

import Epoxy
import UIKit

class QuestionViewController: CollectionViewController {
    var game: Game
    
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
    }
    
    private var state: State {
        didSet {
            setItems(items, animated: true)
            topBarInstaller.setBars(topBars, animated: true)
            bottomBarInstaller.setBars(bottomBars, animated: true)
        }
    }
    
    init(game: Game) {
        let layout = UICollectionViewCompositionalLayout
            .list(using: .init(appearance: .plain))
        self.game = game
        self.state = State(possibleAnswers: [], currentQuestion: "", answerChecked: false, answerSelected: false)
        super.init(layout: layout)
        createStateFromGame(answerChecked: false)
        setItems(items, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topBarInstaller.install()
        bottomBarInstaller.install()
        if game.possibleAnswers.count == 0 {
            self.showText(title: "Error", message: "\(game.description(short: true))\nbrought no choices!")
        }
    }
    
    @ItemModelBuilder
    var items: [ItemModeling] {
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
    
    private func createStateFromGame(answerChecked: Bool) {
        let possibleAnswers = game.possibleAnswers.enumerated().map { (index, possibleAnswer) in
            AnswerItem(selected: false, text: possibleAnswer, answerID: getItemID(position: index))
        }
        state = State(possibleAnswers: possibleAnswers, currentQuestion: game.questionStr, answerChecked: answerChecked, answerSelected: answerChecked)
    }
    
    private func getItemID(position: Int) -> Int {
        return (game.currentStep+1)*100 + position
    }
    
    private func selectItem(id: Int) {
        if let indexFound = state.possibleAnswers.firstIndex(where: {$0.answerID == id}) {
            let possibleAnswers = state.possibleAnswers.enumerated().map { (idx, item) in
                AnswerItem(
                    selected: idx == indexFound,
                    text: item.text,
                    answerID: item.answerID) }
            self.state = State(possibleAnswers: possibleAnswers, currentQuestion: state.currentQuestion, answerChecked: false, answerSelected: true)
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
        ButtonRow.barModel(
            content: .init(text: self.state.answerChecked ? "Next Question" : "Check answer!"),
            behaviors: .init(didTap: {
                if self.state.answerChecked {
                    self.game.next()
                    self.createStateFromGame(answerChecked: false)
                } else {
                    if !self.state.answerSelected {
                        self.showText(title: "Please select an answer", message: "")
                    } else {
                        if let indexFound = self.indexOfSelection() {
                            if self.game.evalAnswer(index: indexFound) {
                                self.showText(title: "Correct answer!", message: "")
                            } else {
                                self.showText(title: "Oops...", message: "incorrect answer")
                            }
                            self.createStateFromGame(answerChecked: true)
                        }
                    }
                }
            }))
    }
    
    @BarModelBuilder
    var topBars: [BarModeling] {
        TextRow.barModel(content: TextRow.Content(title: game.description(), body: game.scoreStr), style: TextRow.Style.small)
        TextRow.barModel(content: TextRow.Content(title: game.currentStepStr, body: state.currentQuestion), style: TextRow.Style.large)
    }
    
    func showText(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
