// Created by Tyler Hedrick on 9/12/19.
// Copyright © 2019 Airbnb Inc. All rights reserved.

import Epoxy
import UIKit

// MARK: - TextRow

final class TextRow: UIView, EpoxyableView {
    
    // MARK: Lifecycle
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layoutMargins = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
        group.install(in: self)
        group.constrainToMarginsWithHighPriorityBottom()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    enum Style {
        case small, large, red, green
    }
    
    struct Content: Equatable {
        var title: String?
        var body: String?
    }
    
    func setContent(_ content: Content, animated _: Bool) {
        let titleStyle: UIFont.TextStyle
        let bodyStyle: UIFont.TextStyle
        let color: UIColor
        
        switch style {
        case .large:
            titleStyle = .headline
            bodyStyle = .body
            color = UIColor.label
        case .small:
            titleStyle = .body
            bodyStyle = .caption1
            color = UIColor.label
        case .red:
            titleStyle = .headline
            bodyStyle = .body
            color = .red
        case .green:
            titleStyle = .headline
            bodyStyle = .body
            color = UIColor(red: 0, green: 0.65, blue: 0.05, alpha: 1.0)
        }
        group.setItems {
            if let title = content.title {
                Label.groupItem(
                    dataID: DataID.title,
                    content: title,
                    style: .style(with: titleStyle,
                                  textAlignment: .left,
                                  color: color))
                .adjustsFontForContentSizeCategory(true)
                .textColor(color)
            }
            if let body = content.body {
                Label.groupItem(
                    dataID: DataID.body,
                    content: body,
                    style: .style(with: bodyStyle,
                                  textAlignment: .left,
                                  color: color))
                .adjustsFontForContentSizeCategory(true)
                .numberOfLines(0)
                .textColor(color)
            }
        }
    }
    
    // MARK: Private
    
    private enum DataID {
        case title
        case body
    }
    
    private let style: Style
    private let group = VGroup(spacing: 8)
}

// MARK: SelectableView

extension TextRow: SelectableView {
    func didSelect() {
        // Handle this row being selected, e.g. to trigger haptics:
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: HighlightableView

extension TextRow: HighlightableView {
    func didHighlight(_ isHighlighted: Bool) {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
            self.transform = isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
        }
    }
}

// MARK: DisplayRespondingView

extension TextRow: DisplayRespondingView {
    func didDisplay(_: Bool) {
        // Handle this row being displayed.
    }
}
