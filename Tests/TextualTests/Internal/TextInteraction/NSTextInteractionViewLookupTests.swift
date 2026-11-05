#if TEXTUAL_ENABLE_TEXT_SELECTION && os(macOS)
  import SwiftUI
  import Testing

  @testable import Textual

  @MainActor
  struct NSTextInteractionViewLookupTests {
    @Test
    func lookupMenuIsOptInAndCoexistsWithExistingActions() throws {
      let (model, view) = try makeSelectionView()
      let initialMenu = try contextMenu(for: view, model: model)
      let lookupSelector = #selector(view.lookUpSelection(_:))
      #expect(!initialMenu.items.contains { $0.action == lookupSelector })

      view.selectionLookup = TextSelectionLookup(title: "Definition", onRequest: {})
      view.selectionAction = TextSelectionAction(title: "Annotation", perform: { _ in })
      let menu = try contextMenu(for: view, model: model)

      #expect(menu.items.contains { $0.action == lookupSelector })
      #expect(menu.items.contains { $0.action == NSSelectorFromString("copy:") })
      #expect(menu.items.contains { $0.action == NSSelectorFromString("share:") })
      #expect(menu.items.filter { !$0.isSeparatorItem }.count == 4)
    }

    @Test
    func keyboardMenuAnchorPreservesSelectionAwayFromViewCenter() throws {
      let (model, view) = try makeSelectionView()
      view.selectionLookup = TextSelectionLookup(title: "Definition", onRequest: {})
      let range = try #require(model.selectedRange)
      let anchor = view.selectionAnchorRect
      #expect(anchor == model.selectionRects(for: range).first?.rect)
      #expect(!anchor.contains(CGPoint(x: view.bounds.midX, y: view.bounds.midY)))

      let menu = try contextMenu(for: view, model: model, anchor: anchor)

      #expect(model.selectedRange == range)
      let item = try #require(menu.items.first { $0.action == #selector(view.lookUpSelection(_:)) })
      let selection = try #require(item.representedObject as? TextLookupSelection)
      #expect(selection.attributedText == model.attributedText(in: range))
    }

    @Test
    func missingSelectionKeepsDefaultKeyboardMenuLocation() throws {
      let (model, view) = try makeSelectionView()
      model.selectedRange = nil
      #expect(view.selectionAnchorRect == view.bounds)
    }

    @Test
    func lookupValidationRequiresEnabledNonblankSelection() throws {
      let (model, view) = try makeSelectionView()
      let item = NSMenuItem(
        title: "Definition", action: #selector(view.lookUpSelection(_:)), keyEquivalent: ""
      )
      #expect(!view.validateUserInterfaceItem(item))

      view.selectionLookup = TextSelectionLookup(title: "Definition", onRequest: {})
      #expect(view.validateUserInterfaceItem(item))

      model.selectedRange = nil
      #expect(!view.validateUserInterfaceItem(item))

      model.selectedRange = TextRange(start: model.startPosition, end: model.startPosition)
      #expect(!view.validateUserInterfaceItem(item))

      let start = try #require(model.position(from: model.startPosition, offset: 4))
      let end = try #require(model.position(from: model.startPosition, offset: 5))
      model.selectedRange = TextRange(start: start, end: end)
      #expect(!view.validateUserInterfaceItem(item))
    }

    @Test
    func crossBlockLookupRemainsAvailableWhenAnnotationIsUnavailable() throws {
      let (model, view) = try makeSelectionView()
      model.selectedRange = TextRange(start: model.startPosition, end: model.endPosition)
      view.selectionLookup = TextSelectionLookup(title: "Definition", onRequest: {})
      view.selectionAction = TextSelectionAction(title: "Annotation", perform: { _ in })

      let menu = try contextMenu(for: view, model: model)

      #expect(menu.items.contains { $0.action == #selector(view.lookUpSelection(_:)) })
      #expect(menu.items.filter { !$0.isSeparatorItem }.count == 3)
    }

    @Test
    func detachedViewDoesNotReportLookupRequest() throws {
      let (_, view) = try makeSelectionView()
      var requests = 0
      view.selectionLookup = TextSelectionLookup(title: "Definition", onRequest: { requests += 1 })

      view.lookUpSelection(nil)

      #expect(requests == 0)
    }

    private func makeSelectionView() throws -> (TextSelectionModel, NSTextInteractionView) {
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let end = try #require(model.position(from: model.startPosition, offset: 4))
      model.selectedRange = TextRange(start: model.startPosition, end: end)
      let view = NSTextInteractionView(
        model: model, exclusionRects: [],
        openURL: OpenURLAction { _ in .handled }, selectionAction: nil
      )
      view.frame = CGRect(x: 0, y: 0, width: 400, height: 200)
      return (model, view)
    }

    private func contextMenu(
      for view: NSTextInteractionView, model: TextSelectionModel, anchor: CGRect? = nil
    ) throws -> NSMenu {
      let range = try #require(model.selectedRange)
      let rect = try #require(anchor ?? model.selectionRects(for: range).first?.rect)
      let event = try #require(
        NSEvent.mouseEvent(
          with: .rightMouseDown,
          location: view.convert(CGPoint(x: rect.midX, y: rect.midY), to: nil),
          modifierFlags: [], timestamp: 0, windowNumber: 0,
          context: nil, eventNumber: 0, clickCount: 1, pressure: 0
        )
      )
      return try #require(view.menu(for: event))
    }
  }
#endif
