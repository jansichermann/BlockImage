#import "BlockImageViewTest.h"
#import "BlockImageView.h"




@interface BlockImageView ()

@property (nonatomic) UIActivityIndicatorView *loadingIndicator;

- (void)clearLoadingUI;
@property (nonatomic) UIImageView *fadeImageView;

@end



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
    
    UIImage *i2 = [[UIImage alloc] init];
    [bi setImage:i2 fade:YES];
    STAssertEquals(bi.fadeImageView.image, i2, @"Expected fadeView to have image");

    STAssertFalse(bi.image == i2, @"Expected images to not yet match");
    
    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    while (bi.fadeImageView.image && [rl runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);

    STAssertEquals(bi.image, i2, @"Expected images to match");
}

- (void)testLoadingIndicator {
    BlockImageView *bi = [[BlockImageView alloc] init];
    STAssertTrue(bi.loadingIndicator == nil, @"Expected no loadingIndicator");
    [bi loadImageFromUrlString:@"abc"];
    STAssertFalse(bi.loadingIndicator == nil, @"Expected loadingIndicator");

    [bi clearLoadingUI];
    STAssertTrue(bi.loadingIndicator == nil, @"Expected no loadingIndicator");
}

- (void)testUnloadingImage {
    BlockImageView *biv = [[BlockImageView alloc] init];
    UIImage *image = [[UIImage alloc] init];
    biv.placeholderImage = image;
    [biv unloadImage];
    STAssertEquals(biv.image, image, @"Expected images to match");
}

@end
