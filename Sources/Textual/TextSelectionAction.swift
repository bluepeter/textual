#if TEXTUAL_ENABLE_TEXT_SELECTION
  import Foundation

  /// An immutable snapshot of one selection inside a rendered text block.
  public struct TextSelectionSnapshot: Equatable, Sendable {
    public enum BlockKind: Equatable, Sendable {
      case prose
      case unsupported
    }

    /// Selected rendered text.
    public let selectedText: String
    /// All rendered text owned by the surrounding `StructuredText` value.
    public let documentText: String
    /// Rendered text in the single block containing the selection.
    public let blockText: String
    /// UTF-16 offsets within `documentText`.
    public let utf16Range: Range<Int>
    /// UTF-16 offsets within `blockText`.
    public let blockUTF16Range: Range<Int>
    public let blockKind: BlockKind

    public init(
      selectedText: String,
      documentText: String,
      blockText: String,
      utf16Range: Range<Int>,
      blockUTF16Range: Range<Int>,
      blockKind: BlockKind
    ) {
      self.selectedText = selectedText
      self.documentText = documentText
      self.blockText = blockText
      self.utf16Range = utf16Range
      self.blockUTF16Range = blockUTF16Range
      self.blockKind = blockKind
    }
  }

  /// A custom action appended to the system menu for a rendered-text selection.
  public struct TextSelectionAction {
    public let title: String
    public let systemImage: String?

    let isAvailable: @MainActor (TextSelectionSnapshot) -> Bool
    let perform: @MainActor (TextSelectionSnapshot) -> Void

    public init(
      title: String,
      systemImage: String? = nil,
      isAvailable: @escaping @MainActor (TextSelectionSnapshot) -> Bool = { _ in true },
      perform: @escaping @MainActor (TextSelectionSnapshot) -> Void
    ) {
      self.title = title
      self.systemImage = systemImage
      self.isAvailable = isAvailable
      self.perform = perform
    }
  }

  /// A persistent rendered-text highlight expressed in UTF-16 document offsets.
  public struct TextSelectionHighlight: Equatable, Sendable {
    public let utf16Range: Range<Int>
    public let isEmphasized: Bool

    public init(utf16Range: Range<Int>, isEmphasized: Bool = false) {
      self.utf16Range = utf16Range
      self.isEmphasized = isEmphasized
    }
  }
#endif
