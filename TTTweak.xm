#import <UIKit/UIKit.h>
#import "src-objc/TTOverlayView.h"
#import "src-objc/TTTranslate.h"

static UIWindow *TTT_FindActiveWindow(void) {
    UIWindow *win = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive &&
                [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *ws = (UIWindowScene *)scene;
                for (UIWindow *w in ws.windows) {
                    if (w.isKeyWindow || w.windowScene) { win = w; break; }
                }
                if (win) break;
            }
        }
    }
    if (!win) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        win = UIApplication.sharedApplication.keyWindow;
#pragma clang diagnostic pop
    }
    return win;
}

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
        UIWindow *window = TTT_FindActiveWindow();
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
    TTTranslate *translator = [TTTranslate new];
    [translator translateText:text completion:^(NSString * _Nullable translatedText, NSError * _Nullable error) {
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

