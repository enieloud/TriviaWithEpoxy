// Created by Tyler Hedrick on 1/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

final class ButtonRow: UIView, EpoxyableView {
  // MARK: Lifecycle

  init() {
    super.init(frame: .zero)
    self.setUp()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  struct Behaviors {
    var didTap: (() -> Void)?
  }

  struct Content: Equatable {
    var text: String?
  }

  func setContent(_ content: Content, animated _: Bool) {
    self.text = content.text
  }

  func setBehaviors(_ behaviors: Behaviors?) {
    self.didTap = behaviors?.didTap
  }

  // MARK: Private

  private let button = UIButton(type: .system)
  private var didTap: (() -> Void)?

  private var text: String? {
    get { self.button.title(for: .normal) }
    set { self.button.setTitle(newValue, for: .normal) }
  }

  private func setUp() {
    translatesAutoresizingMaskIntoConstraints = false
    layoutMargins = UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24)
    backgroundColor = .quaternarySystemFill

    self.button.tintColor = .systemBlue
    self.button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
    self.button.translatesAutoresizingMaskIntoConstraints = false

    addSubview(self.button)
    NSLayoutConstraint.activate([
      self.button.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      self.button.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      self.button.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      self.button.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
    ])

    self.button.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
  }

  @objc
  private func handleTap() {
    self.didTap?()
  }
}
