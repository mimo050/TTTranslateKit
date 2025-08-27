#import "TTTranslate.h"

@implementation TTTranslate

static NSURLSession *TTTranslateSession(void) {
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 15.0;
        config.timeoutIntervalForResource = 30.0;
        session = [NSURLSession sessionWithConfiguration:config];
    });
    return session;
}

+ (void)translateText:(NSString * _Nullable)text
           completion:(TTTranslationCompletion)completion
{
    if (text == nil || text.length == 0) {
        if (completion) completion(nil);
        return;
    }

    // Determine the target language from user defaults or fall back to the app's localization (or English).
    NSString *targetLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:@"TTTargetLanguage"];
    if (targetLanguage.length == 0) {
        targetLanguage = [[NSBundle mainBundle] preferredLocalizations].firstObject ?: @"en";
    }

    NSCharacterSet *allowed = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *escapedText = [text stringByAddingPercentEncodingWithAllowedCharacters:allowed];
    NSString *baseURL = [[NSUserDefaults standardUserDefaults] stringForKey:@"TTTranslationEndpoint"];
    if (baseURL.length == 0) {
        baseURL = @"https://translate.googleapis.com/translate_a/single";
    }
    NSString *urlString = [NSString stringWithFormat:@"%@?client=gtx&sl=auto&tl=%@&dt=t&q=%@",
                           baseURL, targetLanguage, escapedText];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSURLSessionDataTask *task = [TTTranslateSession() dataTaskWithRequest:request
                                                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (completion) completion(nil);
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (![httpResponse isKindOfClass:[NSHTTPURLResponse class]] || httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
            if (completion) completion(nil);
            return;
        }

        if (data.length == 0) {
            if (completion) completion(nil);
            return;
        }

        NSError *parseError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (!json || parseError) {
            if (completion) completion(nil);
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
            if (completion) completion(nil);
            return;
        }

        if (completion) completion(translated);
    }];
    [task resume];
}

@end

