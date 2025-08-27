#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TTTranslationCompletion)(NSString * _Nullable translatedText);

@interface TTTranslate : NSObject

/// Translates the provided text to the user's preferred language.
/// @param text The original text to translate.
/// @param completion Completion block returning translated text or `nil` on failure.
+ (void)translateText:(NSString * _Nullable)text
           completion:(TTTranslationCompletion)completion;

@end

NS_ASSUME_NONNULL_END
