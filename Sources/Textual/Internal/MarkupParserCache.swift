import Foundation

/// Keeps parsed markup stable across temporary SwiftUI view reconstructions.
///
/// Resolution is synchronous so the rendered content participates in the first
/// layout pass instead of replacing an initially empty view on the next update.
@MainActor
final class MarkupParserCache {
  private var attributedString = AttributedString()
  private var markup: String?

  func resolve(_ markup: String, parser: any MarkupParser) -> AttributedString {
    guard markup != self.markup else {
      return attributedString
    }

    attributedString = (try? parser.attributedString(for: markup)) ?? .init()
    self.markup = markup
    return attributedString
  }
}
