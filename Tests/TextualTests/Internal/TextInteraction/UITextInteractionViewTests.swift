#if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(UIKit)
  import SwiftUI
  import Testing
  import UIKit

  @testable import Textual

  @Suite
  @MainActor
  struct UITextInteractionViewTests {
    @Test
    func windowEditingDismissalClearsSelectedRange() throws {
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let selectionEnd = try #require(
        model.position(from: model.startPosition, offset: 4)
      )
      model.selectedRange = TextRange(
        start: model.startPosition,
        end: selectionEnd
      )
      let interactionView = UITextInteractionView(
        model: model,
        exclusionRects: [],
        openURL: OpenURLAction { _ in .handled },
        selectionAction: nil
      )
      let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
      let viewController = UIViewController()
      viewController.view.addSubview(interactionView)
      window.rootViewController = viewController
      window.makeKeyAndVisible()

      defer {
        window.isHidden = true
      }

      #expect(interactionView.becomeFirstResponder())
      #expect(interactionView.isFirstResponder)

      #expect(window.endEditing(false))

      #expect(!interactionView.isFirstResponder)
      #expect(model.selectedRange == nil)
    }
  }
#endif
