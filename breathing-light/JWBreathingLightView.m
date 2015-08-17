//
//  JWBreathingLightView.h
//  iCoupon
//
//  Created by John Wong on 6/11/14.
//  Copyright (c) 2014 John Wong. All rights reserved.
//

#import "JWBreathingLightView.h"

#define MAX_SIZE 24

#define BACK_SIZE 4
#define ANIMATE_TIME 3
#define BACK_POINT_TIME 0.8
#define BACK_POINT_OPACITY 1.0

#define FRONT_SIZE 7
#define FRONT_SMALL_SIZE 6
#define FRONT_BIG_SIZE 9
#define FRONT_POINT_TIME 1.0

@interface JWBreathingLightView()

@property (nonatomic, strong) UIView *backPoint;
@property (nonatomic, strong) UIView *backPointTwo;
@property (nonatomic, strong) UIView *frontPoint;
@property (nonatomic, assign) CGAffineTransform originTransform;

@end

@implementation JWBreathingLightView

@synthesize backPoint = _backPoint;
@synthesize backPointTwo = _backPointTwo;
@synthesize frontPoint = _frontPoint;
@synthesize originTransform;

-(UIView*)createPointView:(NSInteger)type
{
    switch (type) {
        case 1:
        {
            UIView* view = [[UIView alloc] initWithFrame:CGRectMake((MAX_SIZE - BACK_SIZE) / 2.0, (MAX_SIZE - BACK_SIZE) / 2.0, BACK_SIZE, BACK_SIZE)];
            view.layer.cornerRadius = BACK_SIZE / 2.0;
            view.backgroundColor = [UIColor blackColor];
            view.alpha = BACK_POINT_OPACITY;
            return view;
        }
            break;
        case 2:
        {
            UIView* view = [[UIView alloc] initWithFrame:CGRectMake((MAX_SIZE - FRONT_SIZE) / 2.0, (MAX_SIZE - FRONT_SIZE) / 2.0, FRONT_SIZE, FRONT_SIZE)];
            view.layer.cornerRadius = FRONT_SIZE / 2.0;
            view.backgroundColor = HEXCOLOR(0xf70708);
            return view;
        }
    }
    return nil;
}

-(void) startAnimate
{
    [self backPointAnimate];
    [self backPointTwoAnimate];
    [self frontPointAnimate];
}

-(void) backPointAnimate
{
    [self.backPoint.layer removeAllAnimations];
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:MAX_SIZE / BACK_SIZE];
    scaleAnimation.duration = BACK_POINT_TIME;
    scaleAnimation.beginTime = FRONT_POINT_TIME + 0.0;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:BACK_POINT_OPACITY];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    opacityAnimation.duration = scaleAnimation.duration;
    opacityAnimation.beginTime = scaleAnimation.beginTime;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = ANIMATE_TIME;
    group.animations = [NSArray arrayWithObjects:scaleAnimation, opacityAnimation, nil];
    group.repeatCount = CGFLOAT_MAX;
    [self.backPoint.layer addAnimation:group forKey:nil];
}

-(void) backPointTwoAnimate
{
    [self.backPointTwo.layer removeAllAnimations];
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:MAX_SIZE / BACK_SIZE];
    scaleAnimation.duration = BACK_POINT_TIME;
    scaleAnimation.beginTime = FRONT_POINT_TIME + BACK_POINT_TIME * 2 / 3;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:BACK_POINT_OPACITY];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    opacityAnimation.duration = scaleAnimation.duration;
    opacityAnimation.beginTime = scaleAnimation.beginTime;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = ANIMATE_TIME;
    group.animations = [NSArray arrayWithObjects:scaleAnimation, opacityAnimation, nil];
    group.repeatCount = CGFLOAT_MAX;
    [self.backPointTwo.layer addAnimation:group forKey:nil];
}

-(void) frontPointAnimate
{
    [self.frontPoint.layer removeAllAnimations];
    CABasicAnimation *smallAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    smallAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    smallAnimation.toValue = [NSNumber numberWithFloat:FRONT_SMALL_SIZE * 1.0 / FRONT_SIZE];
    smallAnimation.duration = 0.15;
    smallAnimation.beginTime = 0;
    smallAnimation.autoreverses = YES;
    
    CABasicAnimation *bigAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    bigAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    bigAnimation.toValue = [NSNumber numberWithFloat:FRONT_BIG_SIZE * 1.0 / FRONT_SIZE];
    bigAnimation.duration = 0.15;
    bigAnimation.beginTime = 0.3;
    bigAnimation.autoreverses = YES;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = ANIMATE_TIME;
    group.animations = [NSArray arrayWithObjects:smallAnimation, bigAnimation, nil];
    group.repeatCount = CGFLOAT_MAX;
    [self.frontPoint.layer addAnimation:group forKey:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backPoint = [self createPointView:1];
        self.backPointTwo = [self createPointView:1];
        self.frontPoint = [self createPointView:2];
        
        [self addSubview:self.backPoint];
        [self addSubview:self.backPointTwo];
        [self addSubview:self.frontPoint];
        
        [self startAnimate];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startAnimate)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
