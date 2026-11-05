#if TEXTUAL_ENABLE_TEXT_SELECTION && !targetEnvironment(macCatalyst)
  import Foundation
  import Testing

  @testable import Textual

  struct TextSelectionLookupTests {
    @Test
    func lookupRequiresNonblankSelection() throws {
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      #expect(model.lookupSelection() == nil)

      model.selectedRange = TextRange(start: model.startPosition, end: model.startPosition)
      #expect(model.lookupSelection() == nil)

      let start = try #require(model.position(from: model.startPosition, offset: 4))
      let end = try #require(model.position(from: model.startPosition, offset: 5))
      let whitespaceRange = TextRange(start: start, end: end)
      #expect(model.text(in: whitespaceRange) == " ")
      #expect(model.lookupSelection(in: whitespaceRange) == nil)
    }

    @Test
    func lookupPreservesCrossBlockTextAndSelectionAnchor() throws {
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let range = TextRange(start: model.startPosition, end: model.endPosition)
      model.selectedRange = range

      let lookup = try #require(model.lookupSelection())
      #expect(lookup.attributedText == model.attributedText(in: range))
      #expect(lookup.sourceRect == model.selectionRects(for: range).first?.rect)
      #expect(model.selectionSnapshot(in: range) == nil)
    }

    @Test
    func lookupPreservesUnicodeAfterSelectionIsCleared() throws {
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let start = try #require(model.position(from: model.startPosition, offset: 42))
      let end = try #require(model.position(from: model.startPosition, offset: 51))
      let range = TextRange(start: start, end: end)
      model.selectedRange = range
      let expectedText = model.attributedText(in: range)
      let lookup = try #require(model.lookupSelection())

      model.selectedRange = nil

      #expect(lookup.attributedText == expectedText)
      #expect(lookup.attributedText.string.contains("مرحبا"))
      #expect(lookup.attributedText.string.utf16.count == 9)
    }
  }
#endif
