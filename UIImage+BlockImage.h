#import <UIKit/UIKit.h>



/**
 Created by Jan Sichermann on 3/31/13. Copyright (c) 2013 Urban Compass. All rights reserved.
 */

@interface UIImage (BlockImage)

/**-----
 @name Image Scaling
 *------
 */

/**
 @param image The image to be scaled
 @param newSize The size to which to scale the image
 @return The resized image
 */
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

/**
 @param image The image to be resized
 @param maxSize The maximum size of the larger height or width
 @return The resized image
 */
+ (UIImage *)scaleImage:(UIImage *)image maxSize:(int)maxSize;

@end
