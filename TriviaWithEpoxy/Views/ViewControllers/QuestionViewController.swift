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
    }
    
    private var state: State {
        didSet {
            setItems(items, animated: true)
            topBarInstaller.setBars(topBars, animated: true)
        }
    }
    
    init(game: Game) {
        let layout = UICollectionViewCompositionalLayout
            .list(using: .init(appearance: .plain))
        self.game = game
        self.state = State(possibleAnswers: [], currentQuestion: "")
        super.init(layout: layout)
        createStateFromGame()
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
        state.possibleAnswers.map { answerItem in
            TextRow.itemModel(
                dataID: answerItem.answerID,
                content: .init(title: answerItem.text, body: nil),
                style: answerItem.selected ? TextRow.Style.large : TextRow.Style.small)
            .didSelect { [weak self] context in
                self?.selectItem(id: answerItem.answerID)
            }
        }
    }
    
    private func createStateFromGame() {
        let possibleAnswers = game.possibleAnswers.enumerated().map { (index, possibleAnswer) in
            AnswerItem(selected: false, text: possibleAnswer, answerID: getItemID(position: index))
        }
        state = State(possibleAnswers: possibleAnswers, currentQuestion: game.questionStr)
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
            self.state = State(possibleAnswers: possibleAnswers, currentQuestion: state.currentQuestion)
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
            content: .init(text: "Check answer!"),
            behaviors: .init(didTap: {
                if let indexFound = self.indexOfSelection() {
                    if self.game.evalAnswer(index: indexFound) {
                        self.showText(title: "Your answer is:", message: "correct answer")
                    } else {
                        self.showText(title: "Your answer is:", message: "incorrect answer")
                    }
                    self.game.next()
                    self.createStateFromGame()
                }
            }))
    }
    
    @BarModelBuilder
    var topBars: [BarModeling] {
        TextRow.barModel(content: TextRow.Content(title: "Game Type", body: game.description()), style: TextRow.Style.large)
        TextRow.barModel(content: TextRow.Content(title: state.currentQuestion, body: "Choose your answer"), style: TextRow.Style.large)
    }
    
    func showText(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
