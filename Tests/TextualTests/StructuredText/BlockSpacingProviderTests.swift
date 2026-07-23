import SwiftUI
import Testing

@testable import Textual

@MainActor
@Suite
struct BlockSpacingProviderTests {
  private let configuration = StructuredText.BlockSpacingConfiguration(indentationLevel: 0)

  @Test
  func gitHubStylesExposeTheirOuterSpacingSynchronously() {
    let environment = TextEnvironmentValues()

    #expect(
      StructuredText.GitHubParagraphStyle().makeBlockSpacing(
        configuration: configuration,
        environment: environment
      ) == .init(top: 0, bottom: 16)
    )
    #expect(
      StructuredText.GitHubHeadingStyle().makeBlockSpacing(
        configuration: .init(indentationLevel: 0, headingLevel: 2),
        environment: environment
      ) == .init(top: 24, bottom: 16)
    )
  }

  @Test
  func adjacentBlockSpacingCollapsesToTheLargerEdge() {
    let listSpacing = StructuredText.BlockSpacing(top: 0, bottom: 16)
    let headingSpacing = StructuredText.BlockSpacing(top: 24, bottom: 16)
    let paragraphSpacing = StructuredText.BlockSpacing(top: 0, bottom: 16)

    #expect(listSpacing.collapsedDistance(to: headingSpacing, fallback: 0) == 24)
    #expect(listSpacing.collapsedDistance(to: paragraphSpacing, fallback: 0) == 16)
  }

  @Test
  func aStyleWithoutCustomSpacingUsesNativeLayoutSpacing() {
    let spacing = UnspacedParagraphStyle().makeBlockSpacing(
      configuration: configuration,
      environment: TextEnvironmentValues()
    )

    #expect(spacing == .init())
    #expect(spacing.collapsedDistance(to: .init(), fallback: 7) == 7)
  }
}

private struct UnspacedParagraphStyle: StructuredText.ParagraphStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
  }
}
