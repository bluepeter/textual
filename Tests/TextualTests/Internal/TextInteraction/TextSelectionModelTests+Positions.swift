#if TEXTUAL_ENABLE_TEXT_SELECTION && !targetEnvironment(macCatalyst)
  import Foundation
  import SwiftUI
  import Testing

  @testable import Textual

  extension TextSelectionModelTests {
    @Test
    func positionFromOffsetZero() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")

      // when
      let result = model.position(from: model.startPosition, offset: 0)

      // then
      #expect(result == model.startPosition)
    }

    @Test
    func positionFromOffsetOutOfRange() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let start = model.startPosition

      // when
      let result = model.position(from: start, offset: 103)

      // then
      #expect(result == nil)
    }

    @Test
    func positionFromOffset() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let offset = 52
      let expected = TextPosition(
        indexPath: .init(runSlice: 0, run: 0, line: 0, layout: 1),
        affinity: .upstream
      )

      // when
      let result = model.position(from: model.startPosition, offset: offset)

      // then
      #expect(result == expected)
    }

    @Test
    func offsetSamePosition() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")

      // when
      let offset = model.offset(from: model.startPosition, to: model.startPosition)

      // then
      #expect(offset == 0)
    }

    @Test
    func offset() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")

      // when
      let offset = model.offset(from: model.startPosition, to: model.endPosition)

      // then
      #expect(offset == 102)
    }

    @Test
    func offsetBackwards() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let start = TextPosition(
        indexPath: .init(runSlice: 3, run: 3, line: 0, layout: 0),
        affinity: .upstream
      )

      // when
      let offset = model.offset(from: start, to: model.startPosition)

      // then
      #expect(offset == -38)
    }

    @Test
    func closestPositionOnEmptyModel() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "empty")

      // when
      let position = model.closestPosition(to: .zero)

      // then
      #expect(position == nil)
    }

    @Test
    func closestPositionWithinFirstRun() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let point = CGPoint(x: 36.75, y: 25.65)
      let expected = TextPosition(
        indexPath: .init(runSlice: 2, run: 0, line: 0, layout: 0),
        affinity: .downstream
      )

      // when
      let position = model.closestPosition(to: point)

      // then
      #expect(position == expected)
    }

    @Test
    func closestPositionWithinLinkRun() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let point = CGPoint(x: 276.18, y: 25.65)
      let expected = TextPosition(
        indexPath: .init(runSlice: 2, run: 3, line: 0, layout: 0),
        affinity: .downstream
      )

      // when
      let position = model.closestPosition(to: point)

      // then
      #expect(position == expected)
    }

    @Test
    func closestPositionSecondLine() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let point = CGPoint(x: 29.027, y: 47.13)
      let expected = TextPosition(
        indexPath: .init(runSlice: 1, run: 0, line: 1, layout: 0),
        affinity: .downstream
      )

      // when
      let position = model.closestPosition(to: point)

      // then
      #expect(position == expected)
    }

    @Test
    func closestPositionNextLayout() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let point = CGPoint(x: 30.98, y: 82.31)
      let expected = TextPosition(
        indexPath: .init(runSlice: 1, run: 0, line: 0, layout: 1),
        affinity: .downstream
      )

      // when
      let position = model.closestPosition(to: point)

      // then
      #expect(position == expected)
    }

    @Test
    func closestPositionClampsBeforeStart() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let point = CGPoint(x: 6, y: 25.64)

      // when
      let position = model.closestPosition(to: point)

      // then
      #expect(position == model.startPosition)
    }

    @Test
    func closestPositionWithinRange() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let range = TextRange(
        start: .init(
          indexPath: .init(runSlice: 2, run: 0, line: 0, layout: 0),
          affinity: .downstream
        ),
        end: .init(
          indexPath: .init(runSlice: 2, run: 3, line: 0, layout: 0),
          affinity: .upstream
        )
      )
      let point = CGPoint(x: 36.75, y: 25.64)

      // when
      let position = model.closestPosition(to: point, within: range)

      // then
      #expect(position == range.start)
    }

    @Test
    func closestPositionBeforeRange() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let range = TextRange(
        start: .init(
          indexPath: .init(runSlice: 2, run: 0, line: 0, layout: 0),
          affinity: .downstream
        ),
        end: .init(
          indexPath: .init(runSlice: 2, run: 3, line: 0, layout: 0),
          affinity: .upstream
        )
      )
      let point = CGPoint(x: 6, y: 25.6)

      // when
      let position = model.closestPosition(to: point, within: range)

      // then
      #expect(position == range.start)
    }

    @Test
    func closestPositionAfterRange() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let range = TextRange(
        start: .init(
          indexPath: .init(runSlice: 2, run: 0, line: 0, layout: 0),
          affinity: .downstream
        ),
        end: .init(
          indexPath: .init(runSlice: 2, run: 3, line: 0, layout: 0),
          affinity: .upstream
        )
      )
      let point = CGPoint(x: 30.98, y: 82.31)

      // when
      let position = model.closestPosition(to: point, within: range)

      // then
      #expect(position == range.end)
    }

    @Test
    func positionAboveSameLayout() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 1, line: 1, layout: 0),
        affinity: .downstream
      )
      let anchor = position

      // when
      let result = model.positionAbove(position, anchor: anchor)

      // then
      #expect(result != nil)
      #expect(result?.indexPath.line == 0)
      #expect(result?.indexPath.layout == 0)
    }

    @Test
    func positionAboveAcrossLayouts() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 0, line: 0, layout: 1),
        affinity: .downstream
      )
      let anchor = position

      // when
      let result = model.positionAbove(position, anchor: anchor)

      // then
      #expect(result != nil)
      #expect(result?.indexPath.layout == 0)
      #expect(result?.indexPath.line == 1)
    }

    @Test
    func positionAboveFromFirstLine() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 0, line: 0, layout: 0),
        affinity: .downstream
      )
      let anchor = position

      // when
      let result = model.positionAbove(position, anchor: anchor)

      // then
      #expect(result == model.startPosition)
    }

    @Test
    func positionBelowSameLayout() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 1, line: 0, layout: 0),
        affinity: .downstream
      )
      let anchor = position

      // when
      let result = model.positionBelow(position, anchor: anchor)

      // then
      #expect(result != nil)
      #expect(result?.indexPath.line == 1)
      #expect(result?.indexPath.layout == 0)
    }

    @Test
    func positionBelowAcrossLayouts() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 2, line: 1, layout: 0),
        affinity: .upstream
      )
      let anchor = position

      // when
      let result = model.positionBelow(position, anchor: anchor)

      // then
      #expect(result != nil)
      #expect(result?.indexPath.layout == 1)
      #expect(result?.indexPath.line == 0)
    }

    @Test
    func positionBelowFromLastLine() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 4, line: 1, layout: 1),
        affinity: .upstream
      )
      let anchor = position

      // when
      let result = model.positionBelow(position, anchor: anchor)

      // then
      #expect(result == model.endPosition)
    }

  }
#endif
