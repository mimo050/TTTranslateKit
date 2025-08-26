// TTOverlayView.m
#import "TTOverlayView.h"

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
    if (!self.hidden) return;
    self.alpha = 0.0;
    self.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)hideOverlay
{
    if (self.hidden) return;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

@end

