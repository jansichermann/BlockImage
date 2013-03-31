#import "UIImage+BlockImage.h"

@implementation UIImage (BlockImage)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)scaleImage:(UIImage *)image maxSize:(int)maxSize {
    float ratio = 1.f;
    
    if (image.size.width >= image.size.height &&
        image.size.width >= maxSize) {
        ratio = maxSize / image.size.width;
    }
    else if (image.size.width >= maxSize) {
        ratio = maxSize / image.size.height;
    }
    
    int width = (int) floor(ratio * image.size.width);
    int height = (int) floor(ratio * image.size.height);
    
    UIImage *resizedImage = [self imageWithImage:image scaledToSize:CGSizeMake(width, height)];
    
    return resizedImage;
}

@end
