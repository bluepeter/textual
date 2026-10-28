import Foundation
import Testing

@testable import Textual

struct CodeTokenizerTests {
  @Test
  @available(watchOS, unavailable)
  func tokenize() async {
    // given
    let tokenizer = CodeTokenizer()

    // when
    let tokens: [CodeToken] =
      if let tokenizer {
        await tokenizer.tokenize(
          code: "let greeting = \"Hello, world!\"",
          language: "swift"
        )
      } else {
        []
      }

    // then
    #expect(tokenizer != nil)
    #expect(
      tokens == [
        .init(content: "let", type: .keyword),
        .init(content: " greeting ", type: .plain),
        .init(content: "=", type: .operator),
        .init(content: " ", type: .plain),
        .init(content: "\"Hello, world!\"", type: .string),
      ]
    )
  }

  @Test(arguments: [
    ("lisp", "(defun greet (name) (format t \"Hello, ~a!\" name))", "defun"),
    ("scheme", "(define (greet name) (display \"Hello, \"))", "define"),
    ("clojure", "(defn greet [name] (str \"Hello, \" name))", "defn"),
  ])
  @available(watchOS, unavailable)
  func tokenizeLispDialects(language: String, source: String, keyword: String) async throws {
    let tokenizer = try #require(CodeTokenizer())

    let tokens = await tokenizer.tokenize(code: source, language: language)

    #expect(tokens.map(\.content).joined() == source)
    #expect(tokens.contains(.init(content: keyword, type: .keyword)))
  }

  @Test
  @available(watchOS, unavailable)
  func tokenizeUnsupportedLanguage() async {
    // given
    let tokenizer = CodeTokenizer()

    // when
    let tokens: [CodeToken] =
      if let tokenizer {
        await tokenizer.tokenize(
          code: "let greeting = \"Hello, world!\"",
          language: "unsupported"
        )
      } else {
        []
      }

    // then
    #expect(tokenizer != nil)
    #expect(
      tokens == [
        .init(content: "let greeting = \"Hello, world!\"", type: .plain)
      ]
    )
  }
}
