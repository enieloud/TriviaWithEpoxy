//
//  Game.swift
//  Trivialidades
//
//  Created by Enrique Nieloud on 23/12/2020.
//

import Foundation

// MARK: - GameInfo
struct GameInfo {
    var categories: TriviaCategories?
    var difficulty: Difficulty = .easy
    var type: QuestionType = .boolean
    var amount: Int = 10
}

// MARK: - Game
struct Game {
    
    private let gameInfo: GameInfo
    private var score: Int
    private var currentStep: Int
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
                completion(game)
            } else {
                completion(nil)
            }
        }
    }
    
    private mutating func setupPossibleAnswers() {
        if self.questionsAndAnswers.listOfQuestionsWithAnswers.count > 0 {
            if self.questionsAndAnswers.listOfQuestionsWithAnswers[self.currentStep].type == .boolean {
                self.possibleAnswers = ["true","false"]
                self.possibleAnswers.shuffle()
            } else {
                self.possibleAnswers = self.questionsAndAnswers.listOfQuestionsWithAnswers[self.currentStep].incorrectAnswers
                self.possibleAnswers.append(self.questionsAndAnswers.listOfQuestionsWithAnswers[self.currentStep].correctAnswer)
                self.possibleAnswers.shuffle()
            }
        } else {
            self.possibleAnswers = []
        }
    }
    
    func isFinihed() -> Bool {
        currentStep == self.questionsAndAnswers.listOfQuestionsWithAnswers.count-1
    }
    
    mutating func next() {
        assert(!isFinihed());
        currentStep += 1
        setupPossibleAnswers()
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
            return "\(score) pts"
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
    
    func gameDescription() -> String {
        let categName = gameInfo.categories?.currentName() ?? ""
        let difficulty = gameInfo.difficulty.description()
        let description = gameInfo.type.description()
        return "\"\(categName)\", \n \"\(difficulty) level\", \n \"\(description)\"\n\n"
    }
}