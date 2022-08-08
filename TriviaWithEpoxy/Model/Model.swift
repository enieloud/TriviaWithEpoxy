import Foundation

// MARK: - Categories

struct TriviaCategories: Codable {
  let triviaCategories: [TriviaCategory]

  func getName(categId: Int) -> String {
    self.triviaCategories.first { $0.id == categId }?.name ?? ""
  }

  enum CodingKeys: String, CodingKey {
    case triviaCategories = "trivia_categories"
  }

  static func empty() -> TriviaCategories {
    TriviaCategories(triviaCategories: [])
  }
}

// MARK: - TriviaCategory

struct TriviaCategory: Codable {
  let id: Int
  let name: String
  var possibleIcons: [String] {
    var nameFiltered = self.name.filter { $0 != ":" && $0 != "&" }
    if let range = nameFiltered.range(of: "Entertainment") {
      nameFiltered.removeSubrange(range)
    }
    let parts = nameFiltered.components(separatedBy: " ").filter(\.isEmpty)
    return parts
  }

  var group: String {
    self.name.before(first: ":")
  }

  var nameWithoutGroup: String {
    let value = self.name.after(first: ":")
    if value.isEmpty {
      return self.name
    } else {
      return value
    }
  }
}

// MARK: - QuestionsAndAnswers

struct QuestionsAndAnswers: Codable {
  let responseCode: Int
  let listOfQuestionsWithAnswers: [QuestionWithAnswer]

  static func empty() -> QuestionsAndAnswers {
    QuestionsAndAnswers(responseCode: 0, listOfQuestionsWithAnswers: [])
  }

  enum CodingKeys: String, CodingKey {
    case responseCode = "response_code"
    case listOfQuestionsWithAnswers = "results"
  }
}

// MARK: - Result

struct QuestionWithAnswer: Codable {
  let category: String
  let type: QuestionType
  let difficulty: Difficulty
  let question, correctAnswer: String
  let incorrectAnswers: [String]

  enum CodingKeys: String, CodingKey {
    case category
    case type
    case difficulty
    case question
    case correctAnswer = "correct_answer"
    case incorrectAnswers = "incorrect_answers"
  }
}

enum Difficulty: String, CaseIterable, Codable {
  case easy
  case hard
  case medium

  func description() -> String {
    return rawValue.capitalizingFirstLetter()
  }
}

enum QuestionType: String, CaseIterable, Codable {
  case boolean
  case multiple

  func description() -> String {
    if self == .boolean {
      return "True or False question"
    } else {
      return "Multiple Choice"
    }
  }
}
