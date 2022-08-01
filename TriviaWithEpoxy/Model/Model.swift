import Foundation

// MARK: - Categories
struct TriviaCategories: Codable {
    let triviaCategories: [TriviaCategory]
    
    func getName(categId: Int) -> String {
        triviaCategories.first { $0.id == categId }?.name ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case triviaCategories = "trivia_categories"
    }
}

// MARK: - TriviaCategory
struct TriviaCategory: Codable {
    let id: Int
    let name: String
}

// MARK: - QuestionsAndAnswers
struct QuestionsAndAnswers: Codable {
    let responseCode: Int
    let listOfQuestionsWithAnswers: [QuestionWithAnswer]

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
        case category, type, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

enum Difficulty: String, CaseIterable, Codable {
    case easy = "easy"
    case hard = "hard"
    case medium = "medium"

    func description() -> String {
        return self.rawValue.capitalizingFirstLetter()
    }
}

enum QuestionType: String, CaseIterable, Codable {
    case boolean = "boolean"
    case multiple = "multiple"

    func description() -> String {
        if self == .boolean {
            return "True or False question"
        } else {
            return "Multiple Choice"
        }
    }
}
