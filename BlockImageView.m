#define CACHE 1

#import "BlockImageView.h"
#import "DataConnection.h"

#if CACHE
#import "GlobalCache.h"
#endif



@interface BlockImageView ()

@property (nonatomic) DataConnection *imageConnection;
@property (nonatomic) UIImageView *fadeImageView;
@property (nonatomic) UIActivityIndicatorView *loadingIndicator;

@end



@implementation BlockImageView

- (void)loadImage {
    NSAssert(self.imageUrl.length > 0, @"Expected imageUrlString to contain imageUrl");
    if (!self.imageConnection ||
        !self.imageConnection.inProgress) {
        [self loadImageFromUrlString:self.imageUrl];
    }
}

- (void)unloadImage {
    [self.imageConnection cancelAndClear];
    [self clearLoadingUI];
    self.image = self.placeholderImage ? self.placeholderImage : nil;
}

- (void)setImage:(UIImage *)image fade:(BOOL)fade {
    [self clearLoadingUI];
    
    if (self.fadeImageView == nil) {
        self.fadeImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    }

    self.imageConnection = nil;
    self.fadeImageView.contentMode = self.contentMode;
    if (!fade) {
        self.image = image;
    }
    else {
        [self addSubview:self.fadeImageView];
        self.fadeImageView.alpha = 0.f;
        self.fadeImageView.image = image;
        [UIView animateWithDuration:0.4 animations:^{
            self.fadeImageView.alpha = 1.f;
        } completion:^(BOOL finished) {
            self.image = image;
            self.fadeImageView.image = nil;
            [self.fadeImageView removeFromSuperview];
        }];
    }
}

- (void)loadImageFromUrlString:(NSString *)urlString {
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self addSubview:self.loadingIndicator];
    [self.loadingIndicator startAnimating];
    self.loadingIndicator.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2) ;
    
    id cachedResult = nil;
#if CACHE
    cachedResult = [[GlobalCache shared] imageForPath:urlString];
#endif 
    if (cachedResult) {
        [self setImage:cachedResult fade:NO];
        return;
    }
    
    self.imageConnection = [DataConnection withURLString:urlString];
    self.imageConnection.dataBlock = ^UIImage *(NSData *d) {
        return [UIImage imageWithData:d];
    };
    
    __weak BlockImageView *weak_self = self;
    self.imageConnection.completionBlock = ^(DataConnection *c){
        [weak_self imageConnectionDidFinish:c];
    };
    [self.imageConnection start];
}

- (void)imageConnectionDidFinish:(DataConnection *)c {
    if (self.imageConnection == c) {
        [self clearLoadingUI];
    
        if (c.didSucceed) {
            [self setImage:c.dataObject fade:YES];
        }
    }
#if CACHE
    if (c.didSucceed) {
        [[GlobalCache shared] setData:c.connectionData forPath:c.urlString];
        [[GlobalCache shared] setImage:c.dataObject forPath:c.urlString];
    }
#endif
}

- (void)clearLoadingUI {
    self.imageConnection = nil;
    [self.loadingIndicator removeFromSuperview];
    self.loadingIndicator = nil;
}

- (void)prepareForReuse {
    [self unloadImage];
    self.fadeImageView.image = nil;
    [self.fadeImageView removeFromSuperview];
}


@end
