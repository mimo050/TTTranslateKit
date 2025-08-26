#import <Foundation/Foundation.h>

/// A simple translation utility that leverages the Google Translate API to
/// translate text from any source language to a specified target language.
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

@implementation TTTranslate

+ (void)translateText:(NSString *)text
           toLanguage:(NSString *)targetLanguage
           completion:(void(^)(NSString * _Nullable translatedText,
                             NSError * _Nullable error))completion
{
    if (text.length == 0 || targetLanguage.length == 0) {
        NSError *paramError = [NSError errorWithDomain:@"TTTranslateErrorDomain"
                                                  code:0
                                              userInfo:@{NSLocalizedDescriptionKey: @"Invalid parameters"}];
        if (completion) completion(nil, paramError);
        return;
    }

    NSCharacterSet *allowed = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *escapedText = [text stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    NSString *urlString = [NSString stringWithFormat:@"https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=%@&dt=t&q=%@",
                           targetLanguage, escapedText];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (completion) completion(nil, error);
            return;
        }
        if (data.length == 0) {
            NSError *noDataError = [NSError errorWithDomain:@"TTTranslateErrorDomain"
                                                       code:1
                                                   userInfo:@{NSLocalizedDescriptionKey: @"No data received"}];
            if (completion) completion(nil, noDataError);
            return;
        }

        NSError *parseError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (!json || parseError) {
            if (completion) completion(nil, parseError);
            return;
        }
        // Response format: [ [ [ translatedText, originalText, ... ], ... ], ... ]
        NSString *translated = nil;
        if ([json isKindOfClass:[NSArray class]] && [json count] > 0) {
            NSArray *outer = (NSArray *)json;
            if (outer.count > 0 && [outer[0] isKindOfClass:[NSArray class]]) {
                NSArray *inner = outer[0];
                if (inner.count > 0 && [inner[0] isKindOfClass:[NSArray class]]) {
                    NSArray *pair = inner[0];
                    if (pair.count > 0) {
                        translated = pair[0];
                    }
                }
            }
        }
        if (!translated) {
            NSError *missingField = [NSError errorWithDomain:@"TTTranslateErrorDomain"
                                                        code:2
                                                    userInfo:@{NSLocalizedDescriptionKey: @"Missing translated text"}];
            if (completion) completion(nil, missingField);
            return;
        }

        if (completion) completion(translated, nil);
    }];
    [task resume];
}

@end

