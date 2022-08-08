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

  func isValid() -> Bool {
    return self.amount != nil && self.categoryId != nil && self.difficulty != nil && self.type != nil
  }

  func description(_ short: Bool) -> String {
    var categName = ""
    if let categId = categoryId {
      categName = self.categories.getName(categId: categId)
    }
    let difficulty = difficulty?.description() ?? ""
    if short {
      return "\(categName), \(difficulty)"
    }
    let questionType = self.type?.description() ?? ""
    return "\(categName), \(difficulty), \(questionType)"
  }

  static func empty() -> GameInfo {
    GameInfo(categories: TriviaCategories.empty())
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
    self.setupPossibleAnswers()
  }

  static func empty() -> Game {
    Game(
      gameInfo: GameInfo.empty(),
      questionsAndAnswers: QuestionsAndAnswers.empty()
    )
  }

  private mutating func setupPossibleAnswers() {
    if !self.questionsAndAnswers.listOfQuestionsWithAnswers.isEmpty {
      if self.questionsAndAnswers.listOfQuestionsWithAnswers[self.currentStep].type == .boolean {
        self.possibleAnswers = ["true", "false"]
        self.possibleAnswers.shuffle()
      } else {
        self.possibleAnswers = self.questionsAndAnswers.listOfQuestionsWithAnswers[self.currentStep]
          .incorrectAnswers.map { String(htmlEncodedString: $0) ?? "" }
        self.possibleAnswers
          .append(String(
            htmlEncodedString: self.questionsAndAnswers
              .listOfQuestionsWithAnswers[self.currentStep].correctAnswer
          ) ?? "")
        self.possibleAnswers.shuffle()
      }
    } else {
      self.possibleAnswers = []
    }
  }

  func isFinihed() -> Bool {
    (self.currentStep == self.questionsAndAnswers.listOfQuestionsWithAnswers.count - 1) && self.answerChecked
  }

  mutating func next() {
    assert(!self.isFinihed())
    self.currentStep += 1
    self.setupPossibleAnswers()
    self.answerChecked = false
  }

  func isCorrect(index: Int) -> Bool {
    let answer = self.possibleAnswers[index]
    let correctAnswer = self.questionsAndAnswers.listOfQuestionsWithAnswers[self.currentStep].correctAnswer
      .uppercased() == answer.uppercased()
    return correctAnswer
  }

  mutating func evalAnswer(index: Int) -> Bool {
    let answer = self.possibleAnswers[index]
    let correctAnswer = self.questionsAndAnswers.listOfQuestionsWithAnswers[self.currentStep].correctAnswer
      .uppercased() == answer.uppercased()
    if correctAnswer {
      self.score += 1
    }
    self.answerChecked = true
    return correctAnswer
  }

  var currentStepStr: String {
    let totalSteps = self.questionsAndAnswers.listOfQuestionsWithAnswers.count
    return "\(self.currentStep + 1) of \(totalSteps)"
  }

  var scoreStr: String {
    let totalSteps = self.questionsAndAnswers.listOfQuestionsWithAnswers.count
    return "\(self.score) pts of \(totalSteps)"
  }

  var questionStr: String {
    if self.questionsAndAnswers.listOfQuestionsWithAnswers.count > self.currentStep {
      return String(
        htmlEncodedString: self.questionsAndAnswers.listOfQuestionsWithAnswers[self.currentStep]
          .question
      )!
    } else {
      return ""
    }
  }

  var categoryStr: String {
    if self.questionsAndAnswers.listOfQuestionsWithAnswers.count > self.currentStep {
      return self.questionsAndAnswers.listOfQuestionsWithAnswers[self.currentStep].category
    } else {
      return ""
    }
  }

  func description(short: Bool = false) -> String {
    return self.gameInfo.description(short)
  }
}
