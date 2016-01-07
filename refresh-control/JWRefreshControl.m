//
//  JWRefreshControl.m
//  JW
//
//  Created by John Wong on 10/14/15.
//  Copyright © 2015 John Wong. All rights reserved.
//

#import "JWRefreshControl.h"
#import "JWRefreshIndicatorView.h"

typedef enum {
    JWRefreshControlStateStop,
    JWRefreshControlStatePulling,
    JWRefreshControlStateAnimating,
    JWRefreshControlStateRefreshing
} JWRefreshControlState;


@interface JWRefreshControl ()

@property (nonatomic, assign) JWRefreshControlState refreshControlState;
// 使用strong确保回收过程不会出现tableview被回收导致kvo报错。
@property (nonatomic, strong) UIScrollView *scrollView;

@end

static NSString *const kJWRefreshControllContentOffset = @"contentOffset";
static NSString *const kJWRefreshControllPanState = @"pan.state";


@implementation JWRefreshControl {
    JWRefreshIndicatorView *_indicator;
    UIColor *_defaultTintColor;
    CGFloat _originalInsetTop;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    if (self = [super initWithFrame:CGRectMake(0, scrollView.top + scrollView.contentInset.top, APCommonUIGetScreenWidth(), 60)]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.backgroundColor = [UIColor clearColor];
        _defaultTintColor = [UIColor colorWithWhite:0.5 alpha:1];
        [self setupViews];
        [self setRefreshControlState:JWRefreshControlStateStop];
        _scrollView = scrollView;
        [_scrollView addObserver:self forKeyPath:kJWRefreshControllContentOffset options:NSKeyValueObservingOptionNew context:nil];
        [_scrollView addObserver:self forKeyPath:kJWRefreshControllPanState options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)setupViews
{
    _indicator = [[JWRefreshIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _indicator.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_indicator];
}

- (void)setTintColor:(UIColor *)tintColor
{
    if (!tintColor) {
        tintColor = _defaultTintColor;
    }
    _indicator.tintColor = tintColor;
}

- (UIColor *)tintColor
{
    return _indicator.tintColor;
}

- (void)beginRefreshing
{
    _refreshing = YES;
    [self setRefreshControlState:JWRefreshControlStateRefreshing];
}

- (void)endRefreshing
{
    [self setRefreshControlState:JWRefreshControlStateStop];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGPoint center = (CGPoint){
        .x = CGRectGetMidX(self.bounds),
        .y = CGRectGetMidY(self.bounds)};
    _indicator.center = center;
}

- (void)dealloc
{
    [_scrollView removeObserver:self forKeyPath:kJWRefreshControllContentOffset];
}

- (void)addInsetHeight
{
    UIEdgeInsets insets = _scrollView.contentInset;
    _originalInsetTop = insets.top;
    insets.top += self.height;
    CGPoint offset = _scrollView.contentOffset;
    _scrollView.contentInset = insets;
    _scrollView.contentOffset = offset;
}

- (void)removeInsetHeight
{
    UIEdgeInsets insets = _scrollView.contentInset;
    insets.top = _originalInsetTop;
    __weak typeof(self) weakSelf = self;
    if (!UIEdgeInsetsEqualToEdgeInsets(insets, _scrollView.contentInset)) {
        [UIView animateWithDuration:0.4 animations:^{
            weakSelf.scrollView.contentInset = insets;
        } completion:nil];
    }
}

- (void)setRefreshControlState:(JWRefreshControlState)refreshControlState
{
    _refreshControlState = refreshControlState;
    switch (refreshControlState) {
        case JWRefreshControlStateStop: {
            if (_refreshing) {
                [self removeInsetHeight];
            }
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 0.0;
            }];
            [_indicator stopAnimating];
            _refreshing = NO;
            break;
        }
        case JWRefreshControlStatePulling: {
            self.alpha = 1.0;
            break;
        }
        case JWRefreshControlStateAnimating: {
            _refreshing = YES;
            self.alpha = 1.0;
            [_indicator startAnimating];
            break;
        }
        case JWRefreshControlStateRefreshing: {
            [self addInsetHeight];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            break;
        }
    };
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([kJWRefreshControllContentOffset isEqualToString:keyPath]) {
        CGFloat pullHeight = -_scrollView.contentOffset.y - _scrollView.contentInset.top;
        CGFloat triggerHeight = 90;

        // Update the progress arrow
        CGFloat progress = pullHeight / triggerHeight;

        _indicator.progress = progress;
        if (_refreshControlState == JWRefreshControlStateStop) {
            if (pullHeight > 0) {
                self.refreshControlState = JWRefreshControlStatePulling;
            }
        } else if (_refreshControlState == JWRefreshControlStatePulling) {
            if (pullHeight <= 0) {
                self.refreshControlState = JWRefreshControlStateStop;
            } else if (pullHeight >= triggerHeight && _scrollView.isDragging) {
                self.refreshControlState = JWRefreshControlStateAnimating;
            }
        }
    } else if ([kJWRefreshControllPanState isEqualToString:keyPath]) {
        if (_refreshControlState == JWRefreshControlStateAnimating) {
            self.refreshControlState = JWRefreshControlStateRefreshing;
        }
    }
}

@end
