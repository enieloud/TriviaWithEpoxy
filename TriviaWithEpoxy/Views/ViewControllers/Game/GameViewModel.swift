//
//  TriviaViewModel.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 03/08/2022.
//

import Foundation
import RxSwift
import RxCocoa

final class GameViewModel {
    struct AnswerItem {
        var selected: Bool
        var text: String
        var answerID: Int
    }
    
    struct GameViewState {
        let possibleAnswers: [AnswerItem]
        let currentQuestion: String
        let answerChecked: Bool
        let answerSelected: Bool
        let message: String
        
        func with(message: String)->GameViewState {
            GameViewState(possibleAnswers: self.possibleAnswers,
                              currentQuestion: self.currentQuestion,
                              answerChecked: self.answerChecked,
                              answerSelected: self.answerSelected,
                              message: message)
        }
        
        func with(possibleAnswers: [AnswerItem])->GameViewState {
            GameViewState(possibleAnswers: possibleAnswers,
                              currentQuestion: self.currentQuestion,
                              answerChecked: self.answerChecked,
                              answerSelected: self.answerSelected,
                              message: self.message)
        }
        
        func with(currentQuestion: String)->GameViewState {
            GameViewState(possibleAnswers: self.possibleAnswers,
                              currentQuestion: currentQuestion,
                              answerChecked: self.answerChecked,
                              answerSelected: self.answerSelected,
                              message: self.message)
        }
        
        func with(answerChecked: Bool)->GameViewState {
            GameViewState(possibleAnswers: self.possibleAnswers,
                              currentQuestion: self.currentQuestion,
                              answerChecked: answerChecked,
                              answerSelected: self.answerSelected,
                              message: self.message)
        }
        
        static func empty()->GameViewState {
            GameViewState(possibleAnswers: [], currentQuestion: "", answerChecked: false, answerSelected: false, message: "")
        }
    }
    
    private let disposeBag = DisposeBag()
    var gameInfo: GameInfo
    var game: Game?

    private var gameIsCreatingSubject = PublishSubject<Bool>()
    lazy var gameIsCreatingPublisher = gameIsCreatingSubject.asDriver(onErrorJustReturn: false)

    private var gameStateSubject = PublishSubject<GameViewState>()
    lazy var gameStatePublisher = gameStateSubject.asDriver(onErrorJustReturn: GameViewState.empty())

    private var gameViewState: GameViewState {
        didSet {
            gameStateSubject.onNext(gameViewState)
        }
    }

    private var showMessageSubject = PublishSubject<String>()
    lazy var showMessagePublisher = showMessageSubject.asDriver(onErrorJustReturn: "")

    init(gameInfo: GameInfo) {
        self.gameInfo = gameInfo
        gameViewState = GameViewState.empty()
    }
    
    func createGame() {
        gameIsCreatingSubject.onNext(true)
        TriviaAPIClient.newGame(gameInfo: gameInfo)
            .subscribe(onNext: { [weak self] game in
                self?.game = game
                self?.onGameCreated()
                self?.gameIsCreatingSubject.onNext(false)
            },
        onError: { error in
            })
        .disposed(by: disposeBag)
    }
    
    func onGameCreated() {
        guard let game = self.game else {
            return
        }
        if game.possibleAnswers.count == 0 {
            showMessageSubject.onNext("\(game.description(short: true))\nbrought no choices!")
        } else {
            gameViewState = GameViewState(possibleAnswers: mapPossibleAnswers(from: game),
                                                  currentQuestion: game.questionStr,
                                                  answerChecked: false,
                                                  answerSelected: false,
                                                  message: "")
        }
    }
    
    private func mapPossibleAnswers(from game: Game) -> [AnswerItem] {
        return game.possibleAnswers.enumerated().map { (index, possibleAnswer) in
            AnswerItem(selected: false, text: possibleAnswer, answerID: getItemID(position: index))
        }
    }
    
    private func getItemID(position: Int) -> Int {
        guard let game = self.game else {
            return 0
        }
        return (game.currentStep+1)*100 + position
    }
    
    func selectItem(id: Int) {
        if let indexFound = gameViewState.possibleAnswers.firstIndex(where: {$0.answerID == id}) {
            let possibleAnswers = gameViewState.possibleAnswers.enumerated().map { (idx, item) in
                AnswerItem(
                    selected: idx == indexFound,
                    text: item.text,
                    answerID: item.answerID) }
            self.gameViewState = GameViewState(possibleAnswers: possibleAnswers,
                                               currentQuestion: gameViewState.currentQuestion,
                                               answerChecked: false,
                                               answerSelected: true,
                                               message: "")
        }
    }
    
    private func indexOfSelection() -> Int? {
        gameViewState.possibleAnswers.firstIndex { item in
            item.selected
        }
    }

    func getButtonText(game: Game)->String {
        if game.isFinihed() {
            if gameViewState.answerChecked {
                return "Game finished. Your final score is:\(game.scoreStr)"
            } else {
                return "Check answer!"
            }
        } else {
            if gameViewState.answerChecked {
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
        if gameViewState.answerChecked {
            if !game!.isFinihed() {
                game!.next()
            }
        } else {
            if !gameViewState.answerSelected {
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
        gameViewState = gameViewState
            .with(possibleAnswers: mapPossibleAnswers(from: game!))
            .with(currentQuestion: game!.questionStr)
            .with(message: message)
            .with(answerChecked: answerChecked)
        
    }}
