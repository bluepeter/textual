#if TEXTUAL_ENABLE_TEXT_SELECTION && os(macOS)
  import SwiftUI
  import Testing

  @testable import Textual

  @MainActor
  struct NSTextInteractionViewTests {
    @Test
    func selectionSurfaceDoesNotMoveItsWindow() {
      let view = NSTextInteractionView(
        model: TextSelectionModel(),
        exclusionRects: [],
        openURL: OpenURLAction { _ in .handled },
        selectionAction: nil
      )

      // AppKit must deliver dragging to the selection view even in windows
      // whose background is draggable. NSView's default opts into window drag.
      #expect(!view.mouseDownCanMoveWindow)
    }
  }
#endif
