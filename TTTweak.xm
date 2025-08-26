#import <UIKit/UIKit.h>

// Forward declarations for internal classes
@interface TTOverlayView : UIView
- (void)updateTranslatedText:(NSString *)text;
- (void)showOverlay;
- (void)hideOverlay;
@end

@interface TTTranslate : NSObject
+ (void)translateText:(NSString *)text
           toLanguage:(NSString *)targetLanguage
           completion:(void(^)(NSString * _Nullable translatedText,
                             NSError * _Nullable error))completion;
@end

// Determine at runtime if we are running inside the target app.
static BOOL TTIsTargetApp(void) {
    static dispatch_once_t onceToken;
    static BOOL result;
    dispatch_once(&onceToken, ^{
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        result = [bundleID isEqualToString:@"com.zhiliaoapp.musically"];
    });
    return result;
}

// Lazily create and attach the overlay view to the key window.
static TTOverlayView *TTGetOverlay(void) {
    static TTOverlayView *overlay;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect frame = [UIScreen mainScreen].bounds;
        overlay = [[TTOverlayView alloc] initWithFrame:frame];
        overlay.hidden = YES;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            [window addSubview:overlay];
        }
    });
    return overlay;
}

// Hook UILabel's setText: to translate any displayed text.
%hook UILabel

- (void)setText:(NSString *)text {
    %orig;
    if (!TTIsTargetApp() || text.length == 0) return;

    TTOverlayView *overlay = TTGetOverlay();
    [overlay showOverlay];
    [TTTranslate translateText:text toLanguage:@"en" completion:^(NSString * _Nullable translatedText, NSError * _Nullable error) {
        if (translatedText) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [overlay updateTranslatedText:translatedText];
            });
        }
    }];
}

%end

