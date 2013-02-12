//
//  BlockImageView.h
//  nearbyFriends
//
//  Created by jan on 11/20/12.
//  Copyright (c) 2012 in4mation GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlockImageView : UIImageView;

// to be used for lazy loading
@property (nonatomic) NSString *imageUrlString;

- (void)loadImageFromUrlString:(NSString *)urlString;
- (void)prepareForReuse;
- (void)loadImage;
- (void)setImage:(UIImage *)image fade:(BOOL)fade;
@end
