import SwiftUI

extension StructuredText {
  /// Semantic information a block style can use to resolve its outer spacing.
  public struct BlockSpacingConfiguration: Sendable, Hashable {
    /// The block's indentation level within the document structure.
    public let indentationLevel: Int
    /// The heading level, or `nil` when the block is not a heading.
    public let headingLevel: Int?
    /// The fenced-code language hint, or `nil` when unavailable.
    public let languageHint: String?

    /// Creates a block-spacing configuration.
    public init(
      indentationLevel: Int,
      headingLevel: Int? = nil,
      languageHint: String? = nil
    ) {
      self.indentationLevel = indentationLevel
      self.headingLevel = headingLevel
      self.languageHint = languageHint
    }
  }

  /// Supplies outer spacing to `StructuredText` synchronously during layout.
  ///
  /// Block spacing is style metadata rather than a preference emitted by the
  /// style's view hierarchy. This lets the parent block layout know every
  /// block's final spacing during its first layout pass.
  public protocol BlockSpacingProvider {
    /// Resolves the spacing above and below a styled block.
    @MainActor func makeBlockSpacing(
      configuration: BlockSpacingConfiguration,
      environment: TextEnvironmentValues
    ) -> BlockSpacing
  }
}

extension StructuredText.BlockSpacingProvider {
  /// Uses the surrounding layout's native spacing when a style does not
  /// specify custom block spacing.
  public func makeBlockSpacing(
    configuration _: StructuredText.BlockSpacingConfiguration,
    environment _: TextEnvironmentValues
  ) -> StructuredText.BlockSpacing {
    .init()
  }
}
