import Foundation
import Testing

@testable import Textual

@MainActor
@Suite
struct MarkupParserCacheTests {
  @Test
  func resolvesInitialMarkupAndCachesIt() {
    let parser = SpyMarkupParser()
    let cache = MarkupParserCache()

    #expect(cache.resolve("First", parser: parser) == AttributedString("First"))
    #expect(cache.resolve("First", parser: parser) == AttributedString("First"))
    #expect(parser.inputs == ["First"])
  }

  @Test
  func reparsesChangedMarkup() {
    let parser = SpyMarkupParser()
    let cache = MarkupParserCache()

    _ = cache.resolve("First", parser: parser)

    #expect(cache.resolve("Second", parser: parser) == AttributedString("Second"))
    #expect(parser.inputs == ["First", "Second"])
  }
}

@MainActor
private final class SpyMarkupParser: MarkupParser {
  private(set) var inputs: [String] = []

  func attributedString(for input: String) -> AttributedString {
    inputs.append(input)
    return AttributedString(input)
  }
}
