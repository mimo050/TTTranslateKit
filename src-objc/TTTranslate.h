#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TTTranslateCompletion)(NSString * _Nullable translatedText,
                                      NSError * _Nullable error);

@interface TTTranslate : NSObject

/// يترجم النص ثم يستدعي الـcompletion بالنتيجة أو الخطأ.
- (void)translateText:(NSString * _Nonnull)text
           completion:(TTTranslateCompletion)completion;

@end

NS_ASSUME_NONNULL_END
