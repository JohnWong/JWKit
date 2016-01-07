//
//  JWRefreshIndicatorView
//  JW
//
//  Created by John Wong on 10/14/15.
//  Copyright © 2015 John Wong. All rights reserved.
//

#import "JWRefreshIndicatorView.h"

@interface JWRefreshIndicatorInnerView : UIView

@property (nonatomic, strong) CALayer *partLayer;
@property (nonatomic, strong) CAReplicatorLayer *replicatorLayer;

@end

@implementation JWRefreshIndicatorInnerView {
    BOOL _isAnimating;
}

static const CGFloat kJWRefreshIndicatorCount              = 12;
static NSString * const kJWRefreshIndicatorInstanceCount   = @"instanceCount";
static NSString * const kJWRefreshIndicatorOpacity         = @"opacity";
static NSString * const kJWRefreshIndicatorTransform       = @"transform";
static NSString * const kJWRefreshInnerOpacity             = @"opacity";

+ (Class)layerClass {
    return [CAReplicatorLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _partLayer = [self genPartLayer];
        [self.layer addSublayer:_partLayer];
        
        self.replicatorLayer.instanceColor = self.tintColor.CGColor;
        self.replicatorLayer.opaque = NO;
        self.replicatorLayer.allowsGroupOpacity = YES;
        self.replicatorLayer.instanceCount = kJWRefreshIndicatorCount;
        self.replicatorLayer.instanceTransform = CATransform3DMakeRotation(M_PI * 2 / kJWRefreshIndicatorCount, 0, 0, 1);
        [self stopAnimatingInner];
        
    }
    return self;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.replicatorLayer.instanceColor = tintColor.CGColor;
}

- (CAReplicatorLayer *)replicatorLayer {
    return (CAReplicatorLayer *)self.layer;
}

- (CALayer *)genPartLayer {
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(49, 36.25, 2, 7.5);
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    layer.allowsEdgeAntialiasing = YES;
    layer.allowsGroupOpacity = YES;
    layer.cornerRadius = 1;
    return layer;
}

- (void)setProgress:(CGFloat)progress {
    if (!_isAnimating) {
        self.layer.timeOffset = progress;
    }
}

- (void)startAnimating {
    _isAnimating = YES;
    [self.layer removeAnimationForKey:kJWRefreshIndicatorOpacity];
    [self.layer removeAnimationForKey:kJWRefreshIndicatorInstanceCount];
    CGFloat speed = 1.0;
    CABasicAnimation * fade = [CABasicAnimation animationWithKeyPath:kJWRefreshInnerOpacity];
    fade.fromValue = [NSNumber numberWithFloat:1.0];
    fade.toValue = [NSNumber numberWithFloat:0.0];
    fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fade.repeatCount = CGFLOAT_MAX;
    fade.fillMode = kCAFillModeBoth;
    fade.duration = speed;
    CGFloat markerAnimationDuration = speed / kJWRefreshIndicatorCount;
    [_partLayer addAnimation:fade forKey:kJWRefreshInnerOpacity];
    [self.replicatorLayer setInstanceDelay:markerAnimationDuration];
    self.replicatorLayer.speed = 1.0;
    self.replicatorLayer.timeOffset = 0;
    self.replicatorLayer.beginTime = 0;
    self.replicatorLayer.beginTime = speed; 
    
    [self.layer removeAnimationForKey:kJWRefreshIndicatorTransform];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:kJWRefreshIndicatorTransform];
    anim.duration = 1.5;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CATransform3D transform = CATransform3DMakeRotation(M_PI - 0.001, 0, 0, 1);
    anim.toValue = [NSValue valueWithCATransform3D:transform];
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeBoth;
    [self.layer addAnimation:anim forKey:kJWRefreshIndicatorTransform];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self stopAnimatingInner];
}

- (void)stopAnimatingInner {
    [self.layer removeAnimationForKey:kJWRefreshIndicatorTransform];
    [_partLayer removeAnimationForKey:kJWRefreshInnerOpacity];
    self.replicatorLayer.speed = 0;
    CABasicAnimation *instanceAnim = [CABasicAnimation animationWithKeyPath:kJWRefreshIndicatorInstanceCount];
    instanceAnim.fromValue = @(1);
    instanceAnim.toValue = @(kJWRefreshIndicatorCount + 0.5);
    instanceAnim.duration = 1;
    instanceAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    instanceAnim.fillMode = kCAFillModeBoth;
    instanceAnim.removedOnCompletion = YES;
    [self.layer addAnimation:instanceAnim forKey:kJWRefreshIndicatorInstanceCount];
    
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:kJWRefreshIndicatorOpacity];
    opacityAnim.fillMode = kCAFillModeBoth;
    opacityAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    opacityAnim.beginTime = 0.0548792;
    opacityAnim.duration = 0.35;
    opacityAnim.fromValue = @(0);
    opacityAnim.toValue = @(1);
    [self.layer addAnimation:opacityAnim forKey:kJWRefreshIndicatorOpacity];
}

- (void)stopAnimating {
    [self.layer removeAnimationForKey:kJWRefreshIndicatorTransform];
    if (!_isAnimating) {
        [self stopAnimatingInner];
        return;
    }
    
    CGFloat duration = 0.3;
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.duration = duration;
    scale.toValue = @(0);

    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotate.duration = duration;
    rotate.toValue = @(M_PI_2);
    
    CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
    group.duration = duration;
    group.delegate = self;
    group.animations = @[scale, rotate];
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeBoth;
    [self.layer addAnimation:group forKey:kJWRefreshIndicatorTransform];
    
    _isAnimating = NO;
}

@end

@implementation JWRefreshIndicatorView {
    JWRefreshIndicatorInnerView *_indicatorView;
    BOOL _isAnimating;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _indicatorView = [[JWRefreshIndicatorInnerView alloc] initWithFrame:self.bounds];
        _indicatorView.tintColor = self.tintColor;
        [self addSubview:_indicatorView];
    }
    return self;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    _indicatorView.tintColor = tintColor;
}

- (void)setProgress:(CGFloat)progress {
    if (_isAnimating) {
        return;
    }
    [_indicatorView setProgress:progress];
}

- (void)startAnimating {
    _isAnimating = YES;
    [_indicatorView startAnimating];
}

- (void)stopAnimating {
    _isAnimating = NO;
    [_indicatorView stopAnimating];
}


@end
