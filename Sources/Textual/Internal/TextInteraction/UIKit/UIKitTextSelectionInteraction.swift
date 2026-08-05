#if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(UIKit)
  import SwiftUI

  // MARK: - Overview
  //
  // `UIKitTextSelectionInteraction` presents the platform-specific text selection overlay for iOS.
  //
  // The modifier receives a `TextSelectionModel` from `TextSelectionInteraction` and overlays
  // `UIKitTextInteractionOverlay`, which wraps a `UIView` that handles selection gestures and
  // integrates with system edit actions (copy/share). SwiftUI continues to render the text while
  // UIKit manages the selection interaction.

  typealias PlatformTextSelectionInteraction = UIKitTextSelectionInteraction

  struct UIKitTextSelectionInteraction: ViewModifier {
    private let model: TextSelectionModel
    private let selectionAction: TextSelectionAction?

    init(model: TextSelectionModel, selectionAction: TextSelectionAction?) {
      self.model = model
      self.selectionAction = selectionAction
    }

    func body(content: Content) -> some View {
      content.overlayPreferenceValue(OverflowFrameKey.self) { frames in
        UIKitTextInteractionOverlay(
          model: model,
          overflowFrames: frames,
          selectionAction: selectionAction
        )
      }
    }
  }
#endif
