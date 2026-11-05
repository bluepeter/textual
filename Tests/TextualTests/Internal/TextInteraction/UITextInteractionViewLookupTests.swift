#if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(UIKit) && !targetEnvironment(macCatalyst)
  import SwiftUI
  import Testing
  import UIKit

  @testable import Textual

  @Suite
  @MainActor
  struct UITextInteractionViewLookupTests {
    @Test
    func lookupIsOptInAndPreservesSuggestedActions() throws {
      let model = try selectedModel()
      let view = interactionView(model: model)
      let range = try #require(view.selectedTextRange)
      let suggested = UIAction(title: "Existing", identifier: .init("existing")) { _ in }

      #expect(view.editMenu(for: range, suggestedActions: [suggested]) == nil)

      view.selectionLookup = TextSelectionLookup(title: "Definition", onRequest: {})
      let menu = try #require(view.editMenu(for: range, suggestedActions: [suggested]))
      #expect(menu.children.first === suggested)
      #expect(menu.children.last?.accessibilityIdentifier == "textual.lookUp")
      #expect(menu.children.compactMap { ($0 as? UIAction)?.identifier.rawValue }
        == ["existing", "textual.lookUp"])

      let collapsed = TextRangeBox(
        TextRange(start: model.startPosition, end: model.startPosition)
      )
      #expect(view.editMenu(for: collapsed, suggestedActions: [suggested]) == nil)
    }

    @Test
    func lookupAndAnnotationCoexistWithoutChangingCopyAndShare() throws {
      let model = try selectedModel()
      let view = interactionView(model: model)
      view.selectionLookup = TextSelectionLookup(title: "Definition", onRequest: {})
      view.selectionAction = TextSelectionAction(
        title: "Annotation", systemImage: "highlighter", perform: { _ in }
      )
      let range = try #require(view.selectedTextRange)
      let copy = UIAction(title: "Copy", identifier: .init("copy")) { _ in }
      let share = UIAction(title: "Share", identifier: .init("share")) { _ in }

      let menu = try #require(view.editMenu(for: range, suggestedActions: [copy, share]))

      #expect(menu.children[0] === copy)
      #expect(menu.children[1] === share)
      #expect(menu.children.count == 4)
      let actionIDs = menu.children.compactMap { ($0 as? UIAction)?.identifier.rawValue }
      #expect(actionIDs.contains("textual.lookUp"))
      #expect(view.canPerformAction(#selector(UIResponderStandardEditActions.copy(_:)), withSender: nil))
      #expect(!view.canPerformAction(#selector(UIResponderStandardEditActions.cut(_:)), withSender: nil))
    }

    @Test
    func crossBlockLookupDoesNotRequireAnnotationSnapshot() throws {
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      model.selectedRange = TextRange(start: model.startPosition, end: model.endPosition)
      let view = interactionView(model: model)
      view.selectionLookup = TextSelectionLookup(title: "Definition", onRequest: {})
      view.selectionAction = TextSelectionAction(title: "Annotation", perform: { _ in })
      let range = try #require(view.selectedTextRange)

      let menu = try #require(view.editMenu(for: range, suggestedActions: []))

      #expect(menu.children.count == 1)
      #expect((menu.children.first as? UIAction)?.identifier == .init("textual.lookUp"))
    }

    @Test
    func missingHostDoesNotReportLookupRequest() throws {
      let model = try selectedModel()
      let view = interactionView(model: model)
      var requests = 0
      view.selectionLookup = TextSelectionLookup(title: "Definition", onRequest: { requests += 1 })
      let selection = try #require(model.lookupSelection())

      #expect(!view.presentLookup(selection))
      #expect(requests == 0)
      #expect(model.selectedRange != nil)
    }

    @Test
    func menuCapturesSelectionAndAnchorsNativePresentationToItsHost() throws {
      let model = try selectedModel()
      let selection = try #require(model.lookupSelection())
      let view = interactionView(model: model)
      var requests = 0
      view.selectionLookup = TextSelectionLookup(title: "Definition", onRequest: { requests += 1 })
      let range = try #require(view.selectedTextRange)
      let menu = try #require(view.editMenu(for: range, suggestedActions: []))
      let action = try #require(menu.children.compactMap { $0 as? UIAction }.first)
      let host = LookupPresentationRecorder()
      let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))
      window.rootViewController = host
      host.view.addSubview(view)
      view.frame = host.view.bounds
      window.makeKeyAndVisible()
      defer { window.isHidden = true }

      model.selectedRange = nil
      UIButton(primaryAction: action).sendActions(for: .touchUpInside)

      let reference = try #require(host.presentedLookup as? UIReferenceLibraryViewController)
      #expect(requests == 1)
      #expect(reference.modalPresentationStyle == .popover)
      #expect(reference.popoverPresentationController?.sourceView === view)
      #expect(reference.popoverPresentationController?.sourceRect == selection.sourceRect)
      #expect(reference.view.accessibilityIdentifier == "textual.dictionary")
      #expect(!view.presentLookup(selection))
      #expect(requests == 1)

      host.presentedLookup = nil
      #expect(view.presentLookup(selection))
      #expect(requests == 2)
    }

    private func selectedModel() throws -> TextSelectionModel {
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let end = try #require(model.position(from: model.startPosition, offset: 4))
      model.selectedRange = TextRange(start: model.startPosition, end: end)
      return model
    }

    private func interactionView(model: TextSelectionModel) -> UITextInteractionView {
      UITextInteractionView(
        model: model, exclusionRects: [],
        openURL: OpenURLAction { _ in .handled }, selectionAction: nil
      )
    }
  }

  @MainActor
  private final class LookupPresentationRecorder: UIViewController {
    var presentedLookup: UIViewController?

    override var presentedViewController: UIViewController? { presentedLookup }

    override func present(
      _ viewControllerToPresent: UIViewController,
      animated flag: Bool,
      completion: (() -> Void)? = nil
    ) {
      presentedLookup = viewControllerToPresent
      completion?()
    }
  }
#endif
