#if TEXTUAL_ENABLE_TEXT_SELECTION && !targetEnvironment(macCatalyst)
  import Foundation
  import SwiftUI
  import Testing

  @testable import Textual

  struct TextSelectionModelTests {
    @Test
    func urlForPoint() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let hitPoint = CGPoint(x: 276, y: 25)
      let missPoint = CGPoint(x: 36, y: 25)
      let outsidePoint = CGPoint(x: 10, y: 10)

      // when
      let hitURL = model.url(for: hitPoint)
      let missURL = model.url(for: missPoint)
      let outsideURL = model.url(for: outsidePoint)

      // then
      #expect(hitURL == URL(string: "https://example.com"))
      #expect(missURL == nil)
      #expect(outsideURL == nil)
    }

    @Test
    func empty() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "empty")

      // when
      let hasText = model.hasText

      // then
      #expect(hasText == false)
    }

    @Test
    func nonEmpty() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")

      // when
      let hasText = model.hasText

      // then
      #expect(hasText == true)
    }

    @Test
    func startPosition() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let expected = TextPosition(
        indexPath: .init(runSlice: 0, run: 0, line: 0, layout: 0),
        affinity: .downstream
      )

      // when
      let position = model.startPosition

      // then
      #expect(position == expected)
    }

    @Test
    func endPosition() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let expected = TextPosition(
        indexPath: .init(runSlice: 0, run: 4, line: 1, layout: 1),
        affinity: .upstream
      )

      // when
      let position = model.endPosition

      // then
      #expect(position == expected)
    }

    @Test
    func attributedTextCollapsedRange() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let range = TextRange(start: model.startPosition, end: model.startPosition)

      // when
      let attributed = model.attributedText(in: range)

      // then
      #expect(attributed.string.isEmpty)
    }

    @Test
    func attributedTextTwoParagraphs() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let range = TextRange(
        start: TextPosition(
          indexPath: .init(runSlice: 1, run: 2, line: 0, layout: 0),
          affinity: .downstream
        ),
        end: TextPosition(
          indexPath: .init(runSlice: 5, run: 1, line: 0, layout: 1),
          affinity: .upstream
        )
      )

      // when
      let attributed = model.attributedText(in: range)

      // then
      #expect(attributed.string == "paragraph with a link and \u{2067}مرحبا\u{2069}.Another sample")
    }

    @Test
    func selectionSnapshotUsesUTF16OffsetsWithinOneBlock() throws {
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let start = try #require(model.position(from: model.startPosition, offset: 53))
      let end = try #require(model.position(from: model.startPosition, offset: 65))
      let range = TextRange(start: start, end: end)

      let snapshot = try #require(model.selectionSnapshot(in: range))

      #expect(snapshot.utf16Range == 53..<65)
      #expect(snapshot.blockUTF16Range == 2..<14)
      #expect(snapshot.selectedText == utf16Slice(snapshot.documentText, at: snapshot.utf16Range))
      #expect(snapshot.selectedText == utf16Slice(snapshot.blockText, at: snapshot.blockUTF16Range))
      #expect(snapshot.blockKind == .prose)
    }

    @Test
    func selectionSnapshotPreservesBidirectionalUnicode() throws {
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let start = try #require(model.position(from: model.startPosition, offset: 42))
      let end = try #require(model.position(from: model.startPosition, offset: 51))

      let snapshot = try #require(
        model.selectionSnapshot(in: TextRange(start: start, end: end))
      )

      #expect(snapshot.selectedText == utf16Slice(snapshot.documentText, at: 42..<51))
      #expect(snapshot.selectedText.utf16.count == 9)
    }

    @Test
    func selectionSnapshotRejectsCollapsedAndCrossBlockRanges() throws {
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let crossBlockStart = try #require(model.position(from: model.startPosition, offset: 50))
      let crossBlockEnd = try #require(model.position(from: model.startPosition, offset: 55))

      #expect(
        model.selectionSnapshot(
          in: TextRange(start: model.startPosition, end: model.startPosition)
        ) == nil
      )
      #expect(
        model.selectionSnapshot(in: TextRange(start: crossBlockStart, end: crossBlockEnd)) == nil
      )
    }

    @Test
    func persistentSelectionRectsRejectInvalidUTF16Ranges() throws {
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")

      #expect(model.selectionRects(forUTF16Range: -1..<4).isEmpty)
      #expect(model.selectionRects(forUTF16Range: 4..<4).isEmpty)
      #expect(model.selectionRects(forUTF16Range: 0..<103).isEmpty)
      #expect(!model.selectionRects(forUTF16Range: 0..<4).isEmpty)
    }

    #if os(iOS)
      @Test(.disabled())
      @MainActor
      func recordTwoParagraphsBidi() throws {
        let view = StructuredText(
          markdown: """
            This is a **sample** paragraph with a [link](https://example.com) and \u{2067}مرحبا\u{2069}.

            Another *sample* paragraph with `code` and \u{2067}كيف حالك؟\u{2069}.
            """
        ).padding()

        try TextSelectionModel.recordFixture(for: view, named: "two-paragraphs-bidi")
      }
    #endif

    private func utf16Slice(_ text: String, at range: Range<Int>) -> String {
      let utf16 = text.utf16
      let lowerBound = utf16.index(utf16.startIndex, offsetBy: range.lowerBound)
      let upperBound = utf16.index(utf16.startIndex, offsetBy: range.upperBound)
      return String(decoding: utf16[lowerBound..<upperBound], as: UTF16.self)
    }
  }

  extension TextSelectionRect {
    var integral: Self {
      TextSelectionRect(
        rect: rect.integral,
        layoutDirection: layoutDirection,
        containsStart: containsStart,
        containsEnd: containsEnd
      )
    }
  }
#endif
