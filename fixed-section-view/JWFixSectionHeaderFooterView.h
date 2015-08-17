//
//  JWFixSectionHeaderFooterView.h
//  iCoupon
//
//  Created by John Wong on 3/23/15.
//  Copyright (c) 2015 John Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    JWTableViewSectionHeader,
    JWTableViewSectionFooter
} JWTableViewSectionType;

@interface JWFixSectionHeaderFooterView : UIView

- (instancetype)initWithTableView:(UITableView *)tableView section:(NSInteger)section type:(JWTableViewSectionType)type;

@end
