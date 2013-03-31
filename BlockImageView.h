#import <UIKit/UIKit.h>



/**
 An ImageView that relies on DataConnection and GlobalCache to load images from Urls, and display them with a visual crossfade once done
 
 Created by Jan Sichermann on 11/20/12. Copyright (c) 2012 Jan Sichermann. All rights reserved.
 */

@interface BlockImageView : UIImageView;

/**-----
 @name Image
 *------
 */

/**
 Set this to the Url String, then call loadImage at a later point. 
 
 This is especially useful in places where the image may not immediately be on the screen (i.e. UITableViews)
 */
@property (nonatomic) NSString *imageUrl;

/**
 A Placeholder image to be shown while the actual image isn't loaded.
 You should set this if you plan to ever call unloadImage
 */
@property (nonatomic) UIImage *placeholderImage;

@property (nonatomic) BOOL matchSize;

/**
 Call this to load an image from the imageUrl property.
 */
- (void)loadImage;

/**
 Call this to remove the image, this is especially useful to more directly influence memory usage
 */
- (void)unloadImage;

/**
 @param imageUrl Provide a Url to an image
 */
- (void)loadImageFromUrlString:(NSString *)imageUrl;

/**
 This should be called if you use this class in a cell.
 It will unset the image, and cancel all existing connections
 */
- (void)prepareForReuse;

/**
 @param image The image to which the view should be set
 @param fade Whether the image should be cross faded, or simply appear
 This calls setImage:fade:matchSize: passing matchSize.
 */
- (void)setImage:(UIImage *)image fade:(BOOL)fade;

/**
 @param image The image to which the view should be set
 @param fade Whether the image should be cross faded, or simply appear
 @param matchSize If set to yes, the View will resize the image to match its size.
 Be aware that passing matchSize resizes the image on the main thread, potentially blocking it if it is a long running operation.
 */
- (void)setImage:(UIImage *)image fade:(BOOL)fade matchSize:(BOOL)matchSize;
@end
