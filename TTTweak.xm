#import <UIKit/UIKit.h>
#import "src-objc/TTOverlayView.h"
#import "src-objc/TTTranslate.h"

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
    // Retrieve the target language from user defaults. If no preference is set,
    // fall back to the app's preferred localization (or English).
    NSString *targetLang = [[NSUserDefaults standardUserDefaults] stringForKey:@"TTTargetLanguage"];
    if (targetLang.length == 0) {
        targetLang = [[NSBundle mainBundle] preferredLocalizations].firstObject ?: @"en";
    }

    [TTTranslate translateText:text toLanguage:targetLang completion:^(NSString * _Nullable translatedText, NSError * _Nullable error) {
        if (translatedText) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [overlay updateTranslatedText:translatedText];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [overlay hideOverlay];
                });
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [overlay hideOverlay];
            });
        }
    }];
}

%end

