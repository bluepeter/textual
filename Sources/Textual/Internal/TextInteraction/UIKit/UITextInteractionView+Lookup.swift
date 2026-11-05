#if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(UIKit)
  import SwiftUI

  extension UITextInteractionView {
    func lookupAction(in range: TextRange) -> UIAction? {
      guard let selectionLookup, let selection = model.lookupSelection(in: range) else {
        return nil
      }
      let action = UIAction(
        title: selectionLookup.title,
        image: UIImage(systemName: "character.book.closed"),
        identifier: UIAction.Identifier("textual.lookUp")
      ) { [weak self] _ in
        self?.presentLookup(selection)
      }
      action.accessibilityIdentifier = "textual.lookUp"
      return action
    }

    @discardableResult
    func presentLookup(_ selection: TextLookupSelection) -> Bool {
      guard let selectionLookup,
        let window, let enclosingController,
        enclosingController.viewIfLoaded?.window === window
      else { return false }

      var presenter = enclosingController
      while let presented = presenter.presentedViewController {
        guard !(presented is UIReferenceLibraryViewController) else { return false }
        presenter = presented
      }
      guard !presenter.isBeingPresented, !presenter.isBeingDismissed,
        !(presenter is UIAlertController)
      else { return false }

      let controller = UIReferenceLibraryViewController(term: selection.attributedText.string)
      controller.modalPresentationStyle = .popover
      controller.popoverPresentationController?.sourceView = self
      controller.popoverPresentationController?.sourceRect = selection.sourceRect
      controller.view.accessibilityIdentifier = "textual.dictionary"
      presenter.present(controller, animated: true)
      selectionLookup.onRequest()
      return true
    }

    private var enclosingController: UIViewController? {
      var responder: UIResponder? = self
      while let current = responder {
        if let controller = current as? UIViewController { return controller }
        responder = current.next
      }
      return nil
    }
  }
#endif
