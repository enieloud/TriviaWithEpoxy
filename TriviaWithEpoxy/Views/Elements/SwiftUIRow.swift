//
//  SwiftUIRow.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 04/08/2022.
//

import SwiftUI

/// An implementation of `TextRow` in SwiftUI.
struct SwiftUITextRow: View {
  var title: String
  var subtitle: String?
  var icons: [String]

  var body: some View {
    HStack(alignment: .center, spacing: 8) {
      VStack(alignment: .leading, spacing: 8) {
        Text(title)
          .font(Font.body)
          .foregroundColor(Color(.label))
        if let subtitle = subtitle {
          Text(subtitle)
            .font(Font.caption)
            .foregroundColor(Color(.secondaryLabel))
        }
      }
      .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
      // Ensure that the text is aligned to the leading edge of the container when it expands beyond
      // its ideal width, instead of the center (the default).
      .frame(maxWidth: .infinity, alignment: .leading)
      if let icon = Image.findImage(names: icons, ofType: "png") {
        icon.resizable().frame(width: 50, height: 50)
        Spacer(minLength: 20)
      }
    }
  }
}

extension Image {
  static func findImage(names: [String], ofType _: String) -> Image? {
    for name in names {
      if let uiImage = UIImage(named: name) {
        return Image(uiImage: uiImage)
      }
    }
    return nil
  }
}

struct SwiftUITextRowPreview: PreviewProvider {
  static var previews: some View {
    SwiftUITextRow(title: "This is the title", subtitle: "Any subtitle", icons: ["Art"])
  }
}
