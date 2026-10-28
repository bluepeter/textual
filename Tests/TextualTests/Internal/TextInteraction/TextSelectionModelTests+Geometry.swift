#if TEXTUAL_ENABLE_TEXT_SELECTION && !targetEnvironment(macCatalyst)
  import Foundation
  import SwiftUI
  import Testing

  @testable import Textual

  extension TextSelectionModelTests {
    @Test
    func firstRectCollapsedRange() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let range = TextRange(start: model.startPosition, end: model.startPosition)

      // when
      let rect = model.firstRect(for: range)

      // then
      #expect(rect == model.caretRect(for: model.startPosition))
    }

    @Test
    func firstRect() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let range = TextRange(
        start: model.startPosition,
        end: TextPosition(
          indexPath: .init(runSlice: 0, run: 0, line: 1, layout: 0),
          affinity: .upstream
        )
      )
      let expected = CGRect(x: 16, y: 16, width: 278, height: 20)

      // when
      let rect = model.firstRect(for: range)

      // then
      #expect(rect.integral == expected)
    }

    @Test
    func caretRectDownstream() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let expected = CGRect(x: 16, y: 16, width: 1, height: 20)

      // when
      let rect = model.caretRect(for: model.startPosition)

      // then
      #expect(rect.integral == expected)
    }

    @Test
    func caretRectUpstream() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: IndexPath(runSlice: 0, run: 0, line: 0, layout: 0),
        affinity: .upstream
      )
      let expected = CGRect(x: 25, y: 16, width: 2, height: 20)

      // when
      let rect = model.caretRect(for: position)

      // then
      #expect(rect.integral == expected)
    }

    @Test
    func caretRectDownstreamRightToLeft() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: IndexPath(runSlice: 0, run: 1, line: 1, layout: 0),
        affinity: .downstream
      )
      let expected = CGRect(x: 51, y: 38, width: 2, height: 20)

      // when
      let rect = model.caretRect(for: position)

      // then
      #expect(rect.integral == expected)
    }

    @Test
    func caretRectUpstreamRightToLeft() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: IndexPath(runSlice: 0, run: 1, line: 1, layout: 0),
        affinity: .upstream
      )
      let expected = CGRect(x: 47, y: 38, width: 2, height: 20)

      // when
      let rect = model.caretRect(for: position)

      // then
      #expect(rect.integral == expected)
    }

    @Test
    func selectionRectsCollapsedRange() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let range = TextRange(start: model.startPosition, end: model.startPosition)

      // when
      let rects = model.selectionRects(for: range)

      // then
      #expect(rects.isEmpty)
    }

    @Test
    func selectionRectsSingleLine() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let range = TextRange(
        start: model.startPosition,
        end: TextPosition(
          indexPath: .init(runSlice: 3, run: 0, line: 0, layout: 0),
          affinity: .upstream
        )
      )
      let expected: [TextSelectionRect] = [
        .init(
          rect: CGRect(x: 16, y: 16, width: 31, height: 20),
          layoutDirection: .leftToRight,
          containsStart: true,
          containsEnd: true
        )
      ]

      // when
      let rects = model.selectionRects(for: range)

      // then
      #expect(rects.map(\.integral) == expected)
    }

    @Test
    func selectionRectsMultipleLines() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let range = TextRange(
        start: model.startPosition,
        end: TextPosition(
          indexPath: .init(runSlice: 0, run: 2, line: 1, layout: 0),
          affinity: .upstream
        )
      )
      let expected: [TextSelectionRect] = [
        .init(
          rect: CGRect(x: 16, y: 16, width: 278, height: 20),
          layoutDirection: .leftToRight,
          containsStart: true,
          containsEnd: false
        ),
        .init(
          rect: CGRect(x: 16, y: 35, width: 32, height: 23),
          layoutDirection: .leftToRight,
          containsStart: false,
          containsEnd: false
        ),
        .init(
          rect: CGRect(x: 47, y: 35, width: 35, height: 23),
          layoutDirection: .rightToLeft,
          containsStart: false,
          containsEnd: false
        ),
        .init(
          rect: CGRect(x: 81, y: 35, width: 6, height: 23),
          layoutDirection: .leftToRight,
          containsStart: false,
          containsEnd: true
        ),
      ]

      // when
      let rects = model.selectionRects(for: range)

      // then
      #expect(rects.map(\.integral) == expected)
    }

  }
#endif
