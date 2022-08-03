//
//  Readers.swift
//  Trivialidades
//
//  Created by Enrique Nieloud on 24/12/2020.
//

import Foundation
import RxSwift
import Alamofire
struct TriviaAPIClient {
    
    enum ApiError: Error {
        case unknownError
        case httpError(Int)
    }
    
    static func fetchCategories() -> Observable<TriviaCategories> {
        return Observable.create { observer -> Disposable in
            AF.request("https://opentdb.com/api_category.php")
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else {
                            // if no error provided by alamofire return unknownError error instead. Should it never happen here?
                            observer.onError(response.error ?? ApiError.unknownError)
                            return
                        }
                        do {
                            let friends = try JSONDecoder().decode(TriviaCategories.self, from: data)
                            observer.onNext(friends)
                        } catch {
                            observer.onError(error)
                        }
                    case .failure(let error):
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

func readGame(gameInfo: GameInfo, completion: @escaping (QuestionsAndAnswers?) -> Void)
{
    guard let amount = gameInfo.amount,
          let categId = gameInfo.categoryId,
          let difficulty = gameInfo.difficulty,
          let type = gameInfo.type
    else {
        completion(nil)
        return
    }
    let urlStr = "https://opentdb.com/api.php?amount=\(amount)&category=\(categId)&difficulty=\(difficulty.rawValue)&type=\(type.rawValue)"
    let url = URL(string: urlStr)!
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let jsonData = data else {
            completion(nil)
            return
        }
        do {
            let game: QuestionsAndAnswers = try JSONDecoder().decode(QuestionsAndAnswers.self, from: jsonData)
            DispatchQueue.main.async {
                completion(game)
            }
        } catch {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    task.resume()
}
