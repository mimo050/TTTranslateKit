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
            NSString *message;
            switch (error.code) {
                case NSURLErrorNotConnectedToInternet:
                    message = @"Network unavailable";
                    break;
                case NSURLErrorTimedOut:
                    message = @"The request timed out";
                    break;
                default:
                    message = error.localizedDescription ?: @"Unknown network error";
                    break;
            }
            NSError *friendly = [NSError errorWithDomain:@"TTTranslateErrorDomain"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: message}];
            if (completion) completion(nil, friendly);
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (![httpResponse isKindOfClass:[NSHTTPURLResponse class]] || httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
            NSInteger status = httpResponse.statusCode;
            NSString *message;
            if (status == 429) {
                message = @"Rate limit exceeded";
            } else {
                message = [NSHTTPURLResponse localizedStringForStatusCode:status];
            }
            NSError *statusError = [NSError errorWithDomain:@"TTTranslateErrorDomain"
                                                      code:status
                                                  userInfo:@{NSLocalizedDescriptionKey: message}];
            if (completion) completion(nil, statusError);
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

