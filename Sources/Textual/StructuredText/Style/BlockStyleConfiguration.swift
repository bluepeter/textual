import SwiftUI

extension StructuredText {
  /// The properties of a block element passed to styles like paragraphs and block quotes.
  public struct BlockStyleConfiguration {
    /// A type-erased view that contains the block content.
    public struct Label: View {
      init(_ label: some View) {
        self.body = AnyView(label)
      }
      public let body: AnyView
    }

    /// The block content.
    public let label: Label
    /// The indentation level of the block within the document structure.
    public let indentationLevel: Int
    /// Rendered plain text for this block when it has textual content.
    public let plainText: String

    init(label: Label, indentationLevel: Int, plainText: String = "") {
      self.label = label
      self.indentationLevel = indentationLevel
      self.plainText = plainText
    }
  }
}
