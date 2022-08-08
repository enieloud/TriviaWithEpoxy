//
//  Readers.swift
//  Trivialidades
//
//  Created by Enrique Nieloud on 24/12/2020.
//

import Alamofire
import Foundation
import RxSwift

enum TriviaAPIClient {
  enum ApiError: Error {
    case unknownError
    case httpError(Int)
  }

  static func fetchCategories() -> Observable<TriviaCategories> {
    return Observable<TriviaCategories>.create { observer -> Disposable in
      AF.request("https://opentdb.com/api_category.php")
        .responseDecodable(of: TriviaCategories.self) { response in
          switch response.result {
          case .success:

            guard let categories = response.value else {
              // if no error provided by alamofire return unknownError error instead. Should it never happen here?
              observer.onError(response.error ?? ApiError.unknownError)
              return
            }
            observer.onNext(categories)

          case let .failure(error):
            if let statusCode = response.response?.statusCode {
              observer.onError(ApiError.httpError(statusCode))
            } else {
              observer.onError(error)
            }
          }
        }
      return Disposables.create()
    }
  }

  static func newGame(gameInfo: GameInfo) -> Observable<Game> {
    if !gameInfo.isValid() {
      return Observable<Game>.empty()
    }
    return Observable<Game>.create { observer -> Disposable in
      let amount = gameInfo.amount!
      let categId = gameInfo.categoryId!
      let difficulty = gameInfo.difficulty!.rawValue
      let type = gameInfo.type!.rawValue
      AF
        .request(
          "https://opentdb.com/api.php?amount=\(amount)&category=\(categId)&difficulty=\(difficulty)&type=\(type)"
        )
        .responseDecodable(of: QuestionsAndAnswers.self) { response in
          switch response.result {

          case .success:
            guard let questionsAndAnswers = response.value else {
              // if no error provided by alamofire return unknownError error instead. Should it never happen here?
              observer.onError(response.error ?? ApiError.unknownError)
              return
            }
            let game = Game(gameInfo: gameInfo, questionsAndAnswers: questionsAndAnswers)
            observer.onNext(game)

          case let .failure(error):
            if let statusCode = response.response?.statusCode {
              observer.onError(ApiError.httpError(statusCode))
            } else {
              observer.onError(error)
            }
          }
        }
      return Disposables.create()
    }
  }
}
