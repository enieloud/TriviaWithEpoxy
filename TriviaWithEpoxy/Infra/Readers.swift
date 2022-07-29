//
//  Readers.swift
//  Trivialidades
//
//  Created by Enrique Nieloud on 24/12/2020.
//

import Foundation

func readGame(gameInfo: GameInfo, completion: @escaping (QuestionsAndAnswers?) -> Void)
{
    let amount = gameInfo.amount
    let categId = gameInfo.categories?.currentCategoryId ?? 0
    let difficulty = gameInfo.difficulty.rawValue
    let type = gameInfo.type.rawValue
    let urlStr = "https://opentdb.com/api.php?amount=\(amount)&category=\(categId)&difficulty=\(difficulty)&type=\(type)"
    let url = URL(string: urlStr)!
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let jsonData = data else {
            completion(nil)
            return
        }
        do {
            let game: QuestionsAndAnswers = try JSONDecoder().decode(QuestionsAndAnswers.self, from: jsonData)
            completion(game)
        } catch {
            completion(nil)
        }
    }
    task.resume()
}

func readTriviaCategories(completion: @escaping (TriviaCategories?) -> Void)
{
    let url = URL(string: "https://opentdb.com/api_category.php")!
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let jsonData = data else {
            completion(nil)
            return
        }
        do {
            let triviaCategories = try JSONDecoder().decode(TriviaCategories.self, from: jsonData)
            completion(triviaCategories)
        } catch {
            completion(nil)
        }
    }
    task.resume()
}
