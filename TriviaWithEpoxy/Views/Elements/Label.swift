// Created by Tyler Hedrick on 1/22/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import EpoxyCore
import UIKit

// MARK: - Label

final class Label: UILabel, EpoxyableView {
  // MARK: Lifecycle

  init(style: Style) {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    font = style.font
    numberOfLines = style.numberOfLines
    if style.showLabelBackground {
      backgroundColor = .secondarySystemBackground
    }
    textAlignment = style.textAlignment
    textColor = style.color
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  // MARK: StyledView

  struct Style: Hashable {
    let font: UIFont
    let showLabelBackground: Bool
    let textAlignment: NSTextAlignment
    let color: UIColor
    var numberOfLines = 0
  }

  // MARK: ContentConfigurableView

  typealias Content = String

  func setContent(_ content: String, animated _: Bool) {
    text = content
  }
}

extension Label.Style {
  static func style(
    with textStyle: UIFont.TextStyle,
    textAlignment: NSTextAlignment,
    color: UIColor,
    showBackground: Bool = false
  )
    -> Label.Style
  {
    .init(
      font: UIFont.preferredFont(forTextStyle: textStyle),
      showLabelBackground: showBackground,
      textAlignment: textAlignment,
      color: color
    )
  }
}
