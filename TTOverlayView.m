// TTOverlayView.m
#import <UIKit/UIKit.h>

@interface TTOverlayView : UIView

/// Updates the overlay with the provided translated text.
- (void)updateTranslatedText:(NSString *)text;

/// Shows the overlay.
- (void)showOverlay;

/// Hides the overlay.
- (void)hideOverlay;

@end

@interface TTOverlayView ()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation TTOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];

        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.numberOfLines = 0;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];

        self.hidden = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectInset(self.bounds, 8.0, 8.0);
}

- (void)updateTranslatedText:(NSString *)text
{
    self.textLabel.text = text;
}

- (void)showOverlay
{
    self.hidden = NO;
}

- (void)hideOverlay
{
    self.hidden = YES;
}

@end

