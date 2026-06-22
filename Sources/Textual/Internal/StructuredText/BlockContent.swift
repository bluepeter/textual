import SwiftUI

extension StructuredText {
  struct BlockContent<Content: AttributedStringProtocol>: View {
    private let parent: PresentationIntent.IntentType?
    private let content: Content

    init(parent: PresentationIntent.IntentType? = nil, content: Content) {
      self.parent = parent
      self.content = content
    }

    var body: some View {
      let runs = content.blockRuns(parent: parent)

      BlockVStack {
        ForEach(runs.indices, id: \.self) { index in
          let run = runs[index]
          Block(intent: run.intent, content: content[run.range])
        }
      }
    }
  }
}

extension StructuredText {
  struct Block: View {
    private let intent: PresentationIntent.IntentType?
    private let content: AttributedSubstring

    init(intent: PresentationIntent.IntentType?, content: AttributedSubstring) {
      self.intent = intent
      self.content = content
    }

    var body: some View {
      // Resolve each block's base writing direction from its own text so a document can
      // mix directions per paragraph (e.g. an RTL reply followed by an LTR translation).
      // RTL prose then right-aligns and flows right-to-left, with list markers and
      // blockquote bars mirrored. Code and math blocks always stay left-to-right.
      blockBody
        .environment(\.layoutDirection, baseLayoutDirection)
    }

    @ViewBuilder
    private var blockBody: some View {
      switch intent?.kind {
      case .paragraph where content.isMathBlock:
        MathBlock(content)
      case .paragraph:
        Paragraph(content)
      case .header(let level):
        Heading(content, level: level)
      case .orderedList:
        OrderedList(intent: intent, content: content)
      case .unorderedList:
        UnorderedList(intent: intent, content: content)
      case .codeBlock(let languageHint) where languageHint?.lowercased() == "math":
        MathCodeBlock(content)
      case .codeBlock(let languageHint):
        CodeBlock(content, languageHint: languageHint)
      case .blockQuote:
        BlockQuote(intent: intent, content: content)
      case .thematicBreak:
        ThematicBreak(content)
      case .table(let columns):
        Table(intent: intent, content: content, columns: columns)
      default:
        Paragraph(content)
      }
    }

    private var baseLayoutDirection: LayoutDirection {
      switch intent?.kind {
      case .codeBlock, .thematicBreak:
        return .leftToRight
      case .paragraph where content.isMathBlock:
        return .leftToRight
      default:
        return content.characters.baseLayoutDirection
      }
    }
  }
}

private extension Collection where Element == Character {
  /// Base writing direction by Unicode's "first strong character" rule (UAX #9 P2/P3):
  /// the first strongly-directional character decides the paragraph base direction.
  /// Neutral / weak characters (digits, punctuation, whitespace, symbols, emoji) are
  /// skipped; with no strong character the direction defaults to left-to-right.
  var baseLayoutDirection: LayoutDirection {
    for character in self {
      for scalar in character.unicodeScalars {
        switch scalar.value {
        case 0x0590 ... 0x05FF, // Hebrew
             0x0600 ... 0x06FF, // Arabic (includes Persian/Farsi letters)
             0x0700 ... 0x074F, // Syriac
             0x0750 ... 0x077F, // Arabic Supplement
             0x08A0 ... 0x08FF, // Arabic Extended-A
             0xFB1D ... 0xFB4F, // Hebrew presentation forms
             0xFB50 ... 0xFDFF, // Arabic presentation forms-A
             0xFE70 ... 0xFEFF: // Arabic presentation forms-B
          return .rightToLeft
        case 0x0041 ... 0x005A, // A-Z
             0x0061 ... 0x007A, // a-z
             0x00C0 ... 0x024F, // Latin-1 supplement + Latin extended letters
             0x0370 ... 0x03FF, // Greek
             0x0400 ... 0x04FF: // Cyrillic
          return .leftToRight
        default:
          continue
        }
      }
    }
    return .leftToRight
  }
}
