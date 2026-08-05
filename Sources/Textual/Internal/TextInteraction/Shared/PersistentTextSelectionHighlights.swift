#if TEXTUAL_ENABLE_TEXT_SELECTION
  import SwiftUI

  struct TextSelectionHighlightsStyle {
    var highlights: [TextSelectionHighlight] = []
    var color: Color = .accentColor
  }

  struct PersistentTextSelectionHighlights: View {
    let model: TextSelectionModel
    let style: TextSelectionHighlightsStyle

    var body: some View {
      let revision = model.layoutRevision
      Canvas { context, _ in
        _ = revision
        for highlight in style.highlights {
          for selectionRect in model.selectionRects(forUTF16Range: highlight.utf16Range) {
            let rect = selectionRect.rect.integral
            let opacity = highlight.isEmphasized ? 0.35 : 0.2
            context.fill(Path(rect), with: .color(style.color.opacity(opacity)))

            let underline = CGRect(x: rect.minX, y: rect.maxY - 2, width: rect.width, height: 2)
            context.fill(Path(underline), with: .color(style.color))
          }
        }
      }
      .allowsHitTesting(false)
      .accessibilityHidden(true)
    }
  }
#endif
