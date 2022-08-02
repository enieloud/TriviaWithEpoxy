//
//  Game.swift
//  Trivialidades
//
//  Created by Enrique Nieloud on 23/12/2020.
//

import Foundation

// MARK: - GameInfo
struct GameInfo {
    let categories: TriviaCategories
    var categoryId: Int?
    var difficulty: Difficulty?
    var type: QuestionType?
    var amount: Int?
    
    func description(_ short: Bool) -> String {
        var categName = ""
        if let categId = categoryId {
            categName = categories.getName(categId: categId)
        }
        let difficulty = difficulty?.description() ?? ""
        if short {
            return "\(categName), \(difficulty)"
        }
        let questionType = type?.description() ?? ""
        return "\(categName), \(difficulty), \(questionType)"
    }
}

// MARK: - Game
struct Game {
    
    private let gameInfo: GameInfo
    private var score: Int
    private var answerChecked = false
    var currentStep: Int
    let questionsAndAnswers: QuestionsAndAnswers
    var possibleAnswers: [String]
    
    init(gameInfo: GameInfo, questionsAndAnswers: QuestionsAndAnswers) {
        self.gameInfo = gameInfo
        self.questionsAndAnswers = questionsAndAnswers
        self.possibleAnswers = []
        self.score = 0
        self.currentStep = 0
        setupPossibleAnswers()
    }
    
    static func createGame(gameInfo: GameInfo, completion: @escaping (Game?) -> Void) {
        readGame(gameInfo: gameInfo) {
            (q: QuestionsAndAnswers?) in
            if let qa = q {
                let game = Game(gameInfo: gameInfo, questionsAndAnswers: qa)
                DispatchQueue.main.async {
                    completion(game)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    private mutating func setupPossibleAnswers() {
        if self.questionsAndAnswers.listOfQuestionsWithAnswers.count > 0 {
            if self.questionsAndAnswers.listOfQuestionsWithAnswers[self.currentStep].type == .boolean {
                self.possibleAnswers = ["true","false"]
                self.possibleAnswers.shuffle()
            } else {
                self.possibleAnswers = self.questionsAndAnswers.listOfQuestionsWithAnswers[self.currentStep].incorrectAnswers.map { String(htmlEncodedString: $0) ?? "" }
                self.possibleAnswers.append(String(htmlEncodedString:(self.questionsAndAnswers.listOfQuestionsWithAnswers[self.currentStep].correctAnswer) ) ?? "" )
                self.possibleAnswers.shuffle()
            }
        } else {
            self.possibleAnswers = []
        }
    }
    
    func isFinihed() -> Bool {
        (currentStep == self.questionsAndAnswers.listOfQuestionsWithAnswers.count-1) && answerChecked
    }
    
    mutating func next() {
        assert(!isFinihed());
        currentStep += 1
        setupPossibleAnswers()
        answerChecked = false
    }
    
    func isCorrect(index: Int) -> Bool {
        let answer = self.possibleAnswers[index]
        let correctAnswer = questionsAndAnswers.listOfQuestionsWithAnswers[currentStep].correctAnswer.uppercased() == answer.uppercased()
        return correctAnswer
    }
    
    mutating func evalAnswer(index: Int) -> Bool {
        let answer = self.possibleAnswers[index]
        let correctAnswer = questionsAndAnswers.listOfQuestionsWithAnswers[currentStep].correctAnswer.uppercased() == answer.uppercased()
        if correctAnswer {
            score+=1
        }
        answerChecked = true
        return correctAnswer
    }
    
    var currentStepStr: String {
        get {
            let totalSteps = questionsAndAnswers.listOfQuestionsWithAnswers.count
            return "\(currentStep+1) of \(totalSteps)"
        }
    }
    
    var scoreStr: String {
        get {
            let totalSteps = questionsAndAnswers.listOfQuestionsWithAnswers.count
            return "\(score) pts of \(totalSteps)"
        }
    }
    
    var questionStr: String {
        get {
            if questionsAndAnswers.listOfQuestionsWithAnswers.count > currentStep {
                return String(htmlEncodedString: questionsAndAnswers.listOfQuestionsWithAnswers[currentStep].question)!
            } else {
                return ""
            }
        }
    }
    
    var categoryStr: String {
        get {
            if questionsAndAnswers.listOfQuestionsWithAnswers.count > currentStep {
                return questionsAndAnswers.listOfQuestionsWithAnswers[currentStep].category
            } else {
                return ""
            }
        }
    }
    
    func description(short: Bool = false) -> String {
        return gameInfo.description(short)
    }
}
