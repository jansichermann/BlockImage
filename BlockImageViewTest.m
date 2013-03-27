#import "BlockImageViewTest.h"
#import "BlockImageView.h"




@interface BlockImageView ()

@property (nonatomic) UIActivityIndicatorView *loadingIndicator;

- (void)clearLoadingUI;

@end



/**
 Created by Jan on 3/18/13. Copyright (c) 2013 Urban Compass. All rights reserved.
 */

@implementation BlockImageViewTest

- (void)testLoadImageThrows {
    BlockImageView *bi = [[BlockImageView alloc] init];
    
    STAssertThrows([bi loadImage], @"Expected Exception since no url is set");
}

- (void)testLoadImage {
    BlockImageView *bi = [[BlockImageView alloc] init];
    bi.imageUrl = @"http://www.google.com";
    STAssertNoThrow([bi loadImage], @"Expected no throw");
}

- (void)testSetImage {
    BlockImageView *bi = [[BlockImageView alloc] init];
    UIImage *i = [[UIImage alloc] init];
    [bi setImage:i fade:NO];
    STAssertEquals(bi.image, i, @"Expected images to match");
}

- (void)testLoadingIndicator {
    BlockImageView *bi = [[BlockImageView alloc] init];
    STAssertTrue(bi.loadingIndicator == nil, @"Expected no loadingIndicator");
    [bi loadImageFromUrlString:@"abc"];
    STAssertFalse(bi.loadingIndicator == nil, @"Expected loadingIndicator");

    [bi clearLoadingUI];
    STAssertTrue(bi.loadingIndicator == nil, @"Expected no loadingIndicator");
}

@end
