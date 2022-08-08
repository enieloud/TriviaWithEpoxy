//
//  String+Extensions.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 29/07/2022.
//

import Foundation

extension String {
  init?(htmlEncodedString: String) {
    guard let data = htmlEncodedString.data(using: .utf8) else {
      return nil
    }
    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
      .documentType: NSAttributedString.DocumentType.html,
      .characterEncoding: String.Encoding.utf8.rawValue
    ]
    guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
      return nil
    }
    self.init(attributedString.string)
  }

  func capitalizingFirstLetter() -> String {
    return prefix(1).capitalized + dropFirst()
  }

  mutating func capitalizeFirstLetter() {
    self = self.capitalizingFirstLetter()
  }
}

extension String {
  func before(first delimiter: Character) -> String {
    if let index = firstIndex(of: delimiter) {
      let before = prefix(upTo: index)
      return String(before)
    }
    return ""
  }

  func after(first delimiter: Character) -> String {
    if let index = firstIndex(of: delimiter) {
      let after = suffix(from: index).dropFirst()
      return String(after)
    }
    return ""
  }
}
