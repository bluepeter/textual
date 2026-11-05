#if TEXTUAL_ENABLE_TEXT_SELECTION
  import SwiftUI

  /// A localized native dictionary action with a content-free usage callback.
  struct TextSelectionLookup {
    let title: String
    let onRequest: @MainActor () -> Void
  }

  /// Text and geometry captured before native presentation changes focus.
  struct TextLookupSelection {
    let attributedText: NSAttributedString
    let sourceRect: CGRect
    let baselineOrigin: CGPoint
  }

  extension EnvironmentValues {
    @Entry var textSelectionLookup: TextSelectionLookup?
  }
#endif
