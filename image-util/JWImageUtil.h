//
//  JWImageUtil.h
//  iCoupon
//
//  Created by John Wong on 12/25/14.
//  Copyright (c) 2014 John Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JWImageUtil : NSObject

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)rotateImage:(UIImage *)image toDegrees:(CGFloat)degrees;
+ (UIImage *)cropImage:(UIImage *)image inRect:(CGRect)rect;

@end
