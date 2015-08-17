//
//  JWImageUtil.m
//  iCoupon
//
//  Created by John Wong on 12/25/14.
//  Copyright (c) 2014 John Wong. All rights reserved.
//

#import "JWImageUtil.h"

// convert degrees to radians
CGFloat degreesToRadians (CGFloat degrees) {
    return (degrees / 180.0) * M_PI;
}

@implementation JWImageUtil

+ (UIImage *)resizeImage:(UIImage *)image tosize:(CGSize)newSize quality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizeImage:image
                      toSize:newSize
                   transform:[self transformForOrientationWithImage:image size:newSize]
              drawTransposed:drawTransposed
        interpolationQuality:quality];
}

+ (UIImage *)resizeImage:(UIImage *)image
                  toSize:(CGSize)newSize
               transform:(CGAffineTransform)transform
          drawTransposed:(BOOL)transpose
    interpolationQuality:(CGInterpolationQuality)quality {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = image.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
+ (CGAffineTransform)transformForOrientationWithImage:(UIImage *)image size:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default: //fix a warning by jiarui on 2013-2-17
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default://fix a warning by jiarui on 2013-2-17
            break;
    }
    
    return transform;
}

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    return [JWImageUtil resizeImage:image tosize:size quality:kCGInterpolationHigh];
}

+ (UIImage *)rotateImage:(UIImage *)image toDegrees:(CGFloat)degrees {
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame: CGRectMake (0, 0, image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation (degreesToRadians (degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    //[rotatedViewBox release];
    // Create the bitmap context
    UIGraphicsBeginImageContext (rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext ();
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM (bitmap, rotatedSize.width / 2, rotatedSize.height / 2);
    // Rotate the image context
    CGContextRotateCTM (bitmap, degreesToRadians (degrees));
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM (bitmap, 1.0, -1.0);
    CGContextDrawImage (bitmap, CGRectMake (-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
   	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)cropImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

@end
