//
//  JWRefreshIndicatorView.h
//  JW
//
//  Created by John Wong on 10/14/15.
//  Copyright © 2015 John Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWRefreshIndicatorView : UIView

@property (nonatomic) CGFloat progress;
@property (nonatomic) UIColor *tintColor; // default = 0.5 gray, 1.0 alpha

- (void)startAnimating;
- (void)stopAnimating;

@end
