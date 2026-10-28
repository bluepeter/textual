#if TEXTUAL_ENABLE_TEXT_SELECTION && !targetEnvironment(macCatalyst)
  import Foundation
  import SwiftUI
  import Testing

  @testable import Textual

  extension TextSelectionModelTests {
    @Test
    func characterRangeEmptyModel() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "empty")

      // when
      let range = model.characterRange(at: .zero)

      // then
      #expect(range == nil)
    }

    @Test
    func characterRange() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let point = CGPoint(x: 30.98, y: 82.31)
      let expected = TextRange(
        start: .init(
          indexPath: .init(runSlice: 1, run: 0, line: 0, layout: 1),
          affinity: .downstream
        ),
        end: .init(
          indexPath: .init(runSlice: 1, run: 0, line: 0, layout: 1),
          affinity: .upstream
        )
      )

      // when
      let range = model.characterRange(at: point)

      // then
      #expect(range == expected)
    }

    @Test
    func blockRange() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 2, run: 1, line: 0, layout: 0),
        affinity: .downstream
      )
      let expected = TextRange(
        start: .init(
          indexPath: .init(runSlice: 0, run: 0, line: 0, layout: 0),
          affinity: .downstream
        ),
        end: .init(
          indexPath: .init(runSlice: 0, run: 2, line: 1, layout: 0),
          affinity: .upstream
        )
      )

      // when
      let range = model.blockRange(for: position)

      // then
      #expect(range == expected)
    }

    @Test
    func blockStartFromMiddle() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 2, run: 1, line: 0, layout: 0),
        affinity: .downstream
      )
      let expected = TextPosition(
        indexPath: .init(runSlice: 0, run: 0, line: 0, layout: 0),
        affinity: .downstream
      )

      // when
      let result = model.blockStart(for: position)

      // then
      #expect(result == expected)
    }

    @Test
    func blockStartFromStart() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 0, line: 0, layout: 1),
        affinity: .downstream
      )
      let expected = TextPosition(
        indexPath: .init(runSlice: 0, run: 0, line: 0, layout: 0),
        affinity: .downstream
      )

      // when
      let result = model.blockStart(for: position)

      // then
      #expect(result == expected)
    }

    @Test
    func blockStartFromVeryStart() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 0, line: 0, layout: 0),
        affinity: .downstream
      )
      let expected = position

      // when
      let result = model.blockStart(for: position)

      // then
      #expect(result == expected)
    }

    @Test
    func blockEndFromMiddle() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      // Position in middle of first layout
      let position = TextPosition(
        indexPath: .init(runSlice: 2, run: 1, line: 0, layout: 0),
        affinity: .downstream
      )
      let expected = TextPosition(
        indexPath: .init(runSlice: 0, run: 2, line: 1, layout: 0),
        affinity: .upstream
      )

      // when
      let result = model.blockEnd(for: position)

      // then
      #expect(result == expected)
    }

    @Test
    func blockEndFromEnd() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 2, line: 1, layout: 0),
        affinity: .upstream
      )  // end of first layout
      let expected = TextPosition(
        indexPath: .init(runSlice: 0, run: 4, line: 1, layout: 1),
        affinity: .upstream
      )

      // when
      let result = model.blockEnd(for: position)

      // then
      #expect(result == expected)
    }

    @Test
    func blockEndFromVeryEnd() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 4, line: 1, layout: 1),
        affinity: .upstream
      )
      // Expected: same position (no next block)
      let expected = position

      // when
      let result = model.blockEnd(for: position)

      // then
      #expect(result == expected)
    }

    @Test
    func isPositionAtBlockBoundaryAtStart() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 0, line: 0, layout: 0),
        affinity: .downstream
      )

      // when
      let result = model.isPositionAtBlockBoundary(position)

      // then
      #expect(result == true)
    }

    @Test
    func isPositionAtBlockBoundaryAtEnd() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 0, run: 2, line: 1, layout: 0),
        affinity: .upstream
      )

      // when
      let result = model.isPositionAtBlockBoundary(position)

      // then
      #expect(result == true)
    }

    @Test
    func isPositionAtBlockBoundaryInMiddle() throws {
      // given
      let model = try TextSelectionModel(fixtureName: "two-paragraphs-bidi")
      let position = TextPosition(
        indexPath: .init(runSlice: 2, run: 1, line: 0, layout: 0),
        affinity: .downstream
      )

      // when
      let result = model.isPositionAtBlockBoundary(position)

      // then
      #expect(result == false)
    }

  }
#endif
