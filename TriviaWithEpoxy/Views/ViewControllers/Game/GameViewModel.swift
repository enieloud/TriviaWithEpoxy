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
    private let disposeBag = DisposeBag()
    var gameInfo: GameInfo
    init(gameInfo: GameInfo) {
        self.gameInfo = gameInfo
    }
    
    // MARK: - Game
    private var gameSubject = PublishSubject<Game>()
    lazy var gamePublisher = gameSubject.asDriver(onErrorJustReturn: Game.empty())

    func createGame() {
        TriviaAPIClient.newGame(gameInfo: gameInfo)
            .subscribe(onNext: { game in
                self.gameSubject.onNext(game)
            },
        onError: { error in
            })
        .disposed(by: disposeBag)
    }
}
