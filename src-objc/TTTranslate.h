#import <Foundation/Foundation.h>

@interface TTTranslate : NSObject

/// Translates the provided text to the given target language.
/// @param text The original text to translate.
/// @param targetLanguage A language code such as "en" or "ar".
/// @param completion Completion block returning translated text or an error.
+ (void)translateText:(NSString *)text
           toLanguage:(NSString *)targetLanguage
           completion:(void(^)(NSString * _Nullable translatedText,
                             NSError * _Nullable error))completion;

@end
