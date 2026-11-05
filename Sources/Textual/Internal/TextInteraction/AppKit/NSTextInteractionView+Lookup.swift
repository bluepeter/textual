#if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(AppKit) && !targetEnvironment(macCatalyst)
  import SwiftUI

  extension NSTextInteractionView {
    @objc func lookUpSelection(_ sender: Any?) {
      guard let selection = (sender as? NSMenuItem)?.representedObject as? TextLookupSelection
        ?? model.lookupSelection()
      else { return }
      presentLookup(selection)
    }

    @discardableResult
    func presentLookup(_ selection: TextLookupSelection) -> Bool {
      guard let selectionLookup, window != nil else { return false }
      showDefinition(for: selection.attributedText, at: selection.baselineOrigin)
      selectionLookup.onRequest()
      return true
    }
  }
#endif
