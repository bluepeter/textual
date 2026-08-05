#if TEXTUAL_ENABLE_TEXT_SELECTION
  import SwiftUI

  // MARK: - Overview
  //
  // `TextSelectionModel` is the shared state object that backs selection and interaction.
  //
  // Platform views (AppKit/UIKit) mutate `selectedRange` in response to gestures and editing
  // commands. The model delegates layout-specific work to a `TextLayoutCollection`, which can be
  // rebuilt at any time as SwiftUI resolves new `Text.Layout` values. When the layout collection
  // changes, the model attempts to reconcile the current selection into the new layout so the
  // selection stays stable across updates.

  @Observable
  final class TextSelectionModel {
    private(set) var layoutRevision = 0
    var selectedRange: TextRange? {
      willSet {
        selectionWillChange?()
      }
      didSet {
        if selectedRange != nil {
          coordinator?.modelDidSelectText(self)
        }
        selectionDidChange?()
      }
    }

    @ObservationIgnored
    var selectionWillChange: (() -> Void)?

    @ObservationIgnored
    var selectionDidChange: (() -> Void)?

    @ObservationIgnored
    private var layoutCollection: any TextLayoutCollection

    @ObservationIgnored
    private weak var coordinator: TextSelectionCoordinator?

    init(
      layoutCollection: any TextLayoutCollection = EmptyTextLayoutCollection(),
      coordinator: TextSelectionCoordinator? = nil
    ) {
      self.layoutCollection = layoutCollection
      setCoordinator(coordinator)
    }

    func setLayoutCollection(_ layoutCollection: any TextLayoutCollection) {
      guard !layoutCollection.isEqual(to: self.layoutCollection) else {
        return
      }

      let oldLayoutCollection = self.layoutCollection
      self.layoutCollection = layoutCollection
      layoutRevision &+= 1

      guard
        let selectedRange,
        layoutCollection.needsPositionReconciliation(with: oldLayoutCollection)
      else {
        return
      }

      // Try to reconcile the selected text range
      self.selectedRange = layoutCollection.reconcileRange(
        selectedRange,
        from: oldLayoutCollection
      )
    }

    func setCoordinator(_ coordinator: TextSelectionCoordinator?) {
      if self.coordinator === coordinator {
        return
      }

      self.coordinator = coordinator
      coordinator?.register(self)
    }

    func url(for point: CGPoint) -> URL? {
      layoutCollection.url(for: point)
    }

    func layoutIndex(of layout: Text.Layout) -> Int? {
      layoutCollection.index(of: layout)
    }
  }

  extension TextSelectionModel {
    var hasText: Bool {
      layoutCollection.stringLength > 0
    }

    var startPosition: TextPosition {
      layoutCollection.startPosition
    }

    var endPosition: TextPosition {
      layoutCollection.endPosition
    }

    func attributedText(in range: TextRange) -> NSAttributedString {
      layoutCollection.attributedText(in: range)
    }

    func selectionSnapshot(in range: TextRange? = nil) -> TextSelectionSnapshot? {
      guard let range = range ?? selectedRange,
        !range.isCollapsed,
        range.start.indexPath.layout == range.end.indexPath.layout
      else {
        return nil
      }

      let layoutIndex = range.start.indexPath.layout
      guard layoutCollection.layouts.indices.contains(layoutIndex) else {
        return nil
      }

      let block = layoutCollection.layouts[layoutIndex].attributedString
      let blockStart = layoutCollection.layouts.prefix(layoutIndex)
        .map(\.attributedString.length)
        .reduce(0, +)
      let start = layoutCollection.characterIndex(at: range.start)
      let end = layoutCollection.characterIndex(at: range.end)
      let localRange = (start - blockStart)..<(end - blockStart)
      guard localRange.lowerBound >= 0, localRange.upperBound <= block.length else {
        return nil
      }

      let selectedText = block.attributedSubstring(from: NSRange(localRange)).string
      guard !selectedText.isEmpty else { return nil }

      return TextSelectionSnapshot(
        selectedText: selectedText,
        documentText: layoutCollection.layouts.map(\.attributedString.string).joined(),
        blockText: block.string,
        utf16Range: start..<end,
        blockUTF16Range: localRange,
        blockKind: block.selectionBlockKind
      )
    }

    func selectionRects(forUTF16Range range: Range<Int>) -> [TextSelectionRect] {
      guard range.lowerBound >= 0,
        range.lowerBound < range.upperBound,
        range.upperBound <= layoutCollection.stringLength,
        let start = layoutCollection.position(
          from: layoutCollection.startPosition, offset: range.lowerBound),
        let end = layoutCollection.position(
          from: layoutCollection.startPosition, offset: range.upperBound)
      else { return [] }

      return layoutCollection.selectionRects(for: TextRange(start: start, end: end))
    }

    func text(in range: TextRange) -> String {
      attributedText(in: range).string
    }

    func position(from position: TextPosition, offset: Int) -> TextPosition? {
      layoutCollection.position(from: position, offset: offset)
    }

    func offset(from: TextPosition, to: TextPosition) -> Int {
      layoutCollection.characterIndex(at: to) - layoutCollection.characterIndex(at: from)
    }

    func firstRect(for range: TextRange) -> CGRect {
      layoutCollection.firstRect(for: range)
    }

    func caretRect(for position: TextPosition) -> CGRect {
      layoutCollection.caretRect(for: position)
    }

    func selectionRects(for range: TextRange) -> [TextSelectionRect] {
      layoutCollection.selectionRects(for: range)
    }

    func selectionRects(for range: TextRange, layout: Text.Layout) -> [TextSelectionRect] {
      layoutCollection.selectionRects(for: range, layout: layout)
    }

    func closestPosition(to point: CGPoint) -> TextPosition? {
      layoutCollection.closestPosition(to: point)
    }

    func closestPosition(to point: CGPoint, within range: TextRange) -> TextPosition? {
      guard let position = closestPosition(to: point) else { return nil }
      if position <= range.start { return range.start }
      if position >= range.end { return range.end }
      return position
    }

    func isPositionAtBlockBoundary(_ position: TextPosition) -> Bool {
      layoutCollection.isPositionAtBlockBoundary(position)
    }

    func positionAbove(_ position: TextPosition, anchor: TextPosition) -> TextPosition? {
      layoutCollection.positionAbove(position, anchor: anchor)
    }

    func positionBelow(_ position: TextPosition, anchor: TextPosition) -> TextPosition? {
      layoutCollection.positionBelow(position, anchor: anchor)
    }

    func characterRange(at point: CGPoint) -> TextRange? {
      layoutCollection.characterRange(at: point)
    }

    func blockStart(for position: TextPosition) -> TextPosition? {
      layoutCollection.blockStart(for: position)
    }

    func blockEnd(for position: TextPosition) -> TextPosition? {
      layoutCollection.blockEnd(for: position)
    }

    func blockRange(for position: TextPosition) -> TextRange? {
      layoutCollection.blockRange(for: position)
    }

    @available(macOS 10.0, *)
    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    func wordRange(for position: TextPosition) -> TextRange? {
      layoutCollection.wordRange(for: position)
    }

    @available(macOS 10.0, *)
    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    func nextWord(from position: TextPosition) -> TextPosition? {
      layoutCollection.nextWord(from: position)
    }

    @available(macOS 10.0, *)
    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    func previousWord(from position: TextPosition) -> TextPosition? {
      layoutCollection.previousWord(from: position)
    }
  }

  extension NSAttributedString {
    fileprivate var selectionBlockKind: TextSelectionSnapshot.BlockKind {
      guard length > 0 else { return .unsupported }

      var result = TextSelectionSnapshot.BlockKind.unsupported
      enumerateAttribute(
        .textual.presentationIntent,
        in: NSRange(location: 0, length: length)
      ) { value, _, stop in
        guard let intent = value as? PresentationIntent,
          let kind = intent.components.first?.kind
        else { return }

        switch kind {
        case .paragraph, .header:
          result = .prose
          stop.pointee = true
        default:
          break
        }
      }
      return result
    }
  }
#endif
