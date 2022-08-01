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
        var answerID: String
    }
    
    private var state = [AnswerItem]() {
        didSet {
            setItems(items, animated: true)
        }
    }
    
    init(game: Game) {
        let layout = UICollectionViewCompositionalLayout
            .list(using: .init(appearance: .plain))
        self.game = game
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
        state.map { answerItem in
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
        self.state = game.possibleAnswers.map {
            AnswerItem(selected: false, text: $0, answerID: game.questionStr+$0)
        }
    }
    
    private func selectItem(id: String) {
        if let indexFound = state.firstIndex(where: {$0.answerID == id}) {
            let newState = state.enumerated().map { (idx, item) in
                AnswerItem(
                    selected: idx == indexFound,
                    text: item.text,
                    answerID: item.answerID)
            }
            self.state = newState
        }
    }
    
    private func indexOfSelection() -> Int? {
        state.firstIndex {item in
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
                }
            }))
    }
    @BarModelBuilder
    var topBars: [BarModeling] {
        TextRow.barModel(content: TextRow.Content(title: "Game Type", body: game.description()), style: TextRow.Style.large)
        TextRow.barModel(content: TextRow.Content(title: game.questionStr, body: "Choose your answer"), style: TextRow.Style.large)
    }
    
    func showText(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
