#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTOverlayView : UIView

/// Updates the overlay with the provided translated text.
- (void)updateTranslatedText:(NSString *)text;

/// Shows the overlay.
- (void)showOverlay;

/// Hides the overlay.
- (void)hideOverlay;

@end

NS_ASSUME_NONNULL_END
