//
//  JWRefreshControl.h
//  JW
//
//  Created by John Wong on 10/14/15.
//  Copyright © 2015 John Wong. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JWRefreshControl : UIControl

- (instancetype)initWithScrollView:(UIScrollView *)scrollView;

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

// This 'Tint Color' will set the text color and spinner color
@property (nonatomic, retain) UIColor *tintColor UI_APPEARANCE_SELECTOR; // Default = 0.5 gray, 1.0 alpha

// May be used to indicate to the refreshControl that an external event has initiated the refresh action
- (void)beginRefreshing;
// Must be explicitly called when the refreshing has completed
- (void)endRefreshing;

@end
