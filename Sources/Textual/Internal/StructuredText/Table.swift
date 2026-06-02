import SwiftUI

// MARK: - Overview
//
// Table uses a two-pass layout system. The first pass renders cells which emit their bounds via
// preferences. The second pass collects all cell bounds, transforms them from anchor coordinates
// to geometry coordinates, and builds a `TableLayout` that the style uses to render overlays
// (such as grid lines) and backgrounds with precise cell positions.

extension StructuredText {
  struct Table: View {
    @Environment(\.tableStyle) private var tableStyle

    @State private var spacing = TableCell.Spacing()

    private let intent: PresentationIntent.IntentType?
    private let content: AttributedSubstring
    private let columns: [PresentationIntent.TableColumn]

    init(
      intent: PresentationIntent.IntentType?,
      content: AttributedSubstring,
      columns: [PresentationIntent.TableColumn]
    ) {
      self.intent = intent
      self.content = content
      self.columns = columns
    }

    var body: some View {
      let configuration = TableStyleConfiguration(
        label: .init(label),
        indentationLevel: indentationLevel
      )
      let resolvedStyle = tableStyle.resolve(configuration: configuration)
        .onPreferenceChange(TableCell.SpacingKey.self) { @MainActor in
          spacing = $0
        }

      AnyView(resolvedStyle)
    }

    @ViewBuilder
    private var label: some View {
      let rowRuns = content.blockRuns(parent: intent)

      Grid(horizontalSpacing: spacing.horizontal, verticalSpacing: spacing.vertical) {
        ForEach(rowRuns.indices, id: \.self) { rowIndex in
          let rowRun = rowRuns[rowIndex]
          let rowContent = content[rowRun.range]
          let columnRuns = rowContent.blockRuns(parent: rowRun.intent)
          // Foundation omits a run for any empty cell, so iterating `columnRuns`
          // positionally would shift every cell after the gap one column left
          // (an empty leading header collapses onto the wrong columns). Instead
          // lay each cell out at the column ordinal carried by its `tableCell`
          // intent, leaving an empty cell where a run is missing.
          let cellRanges = Self.cellRanges(columnRuns, declaredColumns: columns.count)

          GridRow {
            ForEach(cellRanges.indices, id: \.self) { columnIndex in
              let cellContent = cellRanges[columnIndex].map { rowContent[$0] }

              TableCell(cellContent, row: rowIndex, column: columnIndex)
                .gridColumnAlignment(alignment(for: columnIndex))
            }
          }
        }
      }
    }

    /// Maps a row's block runs to a dense, column-indexed array of cell ranges.
    ///
    /// Foundation tags every table cell with its ordinal via
    /// `PresentationIntent.Kind.tableCell(columnIndex:)` but emits no run at all
    /// for a cell with no text. Placing runs by that ordinal — rather than by
    /// their position in `columnRuns` — keeps columns aligned across rows even
    /// when a cell is empty. Slots with no run are `nil` and render blank.
    ///
    /// If any run lacks an ordinal (defensive: malformed/unexpected input) we
    /// fall back to the original positional layout for that row.
    private static func cellRanges(
      _ columnRuns: AttributedString.BlockRuns,
      declaredColumns: Int
    ) -> [Range<AttributedString.Index>?] {
      let ordinals = columnRuns.indices.map { columnOrdinal(of: columnRuns[$0]) }

      guard ordinals.allSatisfy({ $0 != nil }) else {
        return columnRuns.indices.map { columnRuns[$0].range }
      }

      let maxOrdinal = ordinals.compactMap { $0 }.max() ?? -1
      let width = max(declaredColumns, maxOrdinal + 1)
      var ranges = [Range<AttributedString.Index>?](repeating: nil, count: width)
      for runIndex in columnRuns.indices {
        if let column = ordinals[runIndex], column < width {
          ranges[column] = columnRuns[runIndex].range
        }
      }
      return ranges
    }

    private static func columnOrdinal(
      of run: AttributedString.BlockRuns.BlockRun
    ) -> Int? {
      guard case .tableCell(let columnIndex)? = run.intent?.kind else {
        return nil
      }
      return columnIndex
    }

    private var indentationLevel: Int {
      content.runs.first?.presentationIntent?.indentationLevel ?? 0
    }

    private func alignment(for columnIndex: Int) -> HorizontalAlignment {
      guard columnIndex < columns.count else {
        return .leading
      }

      switch columns[columnIndex].alignment {
      case .left:
        return .leading
      case .center:
        return .center
      case .right:
        return .trailing
      @unknown default:
        return .leading
      }
    }
  }
}
