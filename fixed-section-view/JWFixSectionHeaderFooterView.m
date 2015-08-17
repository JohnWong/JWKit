//
//  JWFixSectionHeaderFooterView.m
//  iCoupon
//
//  Created by John Wong on 3/23/15.
//  Copyright (c) 2015 John Wong. All rights reserved.
//

#import "JWFixSectionHeaderFooterView.h"

@interface JWFixSectionHeaderFooterView ()

@property NSUInteger section;
@property JWTableViewSectionType type;
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation JWFixSectionHeaderFooterView

- (instancetype)initWithTableView:(UITableView *)tableView section:(NSInteger)section type:(JWTableViewSectionType)type {
    if (self = [super init]) {
        self.tableView = tableView;
        self.section = section;
        self.type = type;
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    CGRect sectionRect = [self.tableView rectForSection:self.section];
    CGFloat top = 0;
    switch (self.type) {
        case JWTableViewSectionHeader:
            top = CGRectGetMinY(sectionRect);
            break;
        case JWTableViewSectionFooter:
            top = CGRectGetMaxY(sectionRect) - CGRectGetHeight(frame);
        default:
            break;
    }
    CGRect newFrame = CGRectMake(CGRectGetMinX(frame),
                                 top,
                                 CGRectGetWidth(frame),
                                 CGRectGetHeight(frame));
    [super setFrame:newFrame];
}

@end
