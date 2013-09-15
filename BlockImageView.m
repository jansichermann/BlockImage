#define CACHE 1
#define ON_ACTIVE_LOAD CACHE && 1

#import "BlockImageView.h"
#import "DataConnection.h"

#import "UIImage+BlockImage.h"

#if CACHE
#import "GlobalCache.h"
#endif

#pragma clang diagnostic ignored "-Wconversion"
#pragma clang diagnostic ignored "-Wunused-parameter"

@interface BlockImageView ()

@property (nonatomic) DataConnection *imageConnection;
@property (nonatomic) UIImageView *fadeImageView;
@property (nonatomic) UIActivityIndicatorView *loadingIndicator;

@end



@implementation BlockImageView

- (void)dealloc {
    [self unregisterObservers];
}
- (id)init {
    [NSException raise:@"NDI" format:nil];
    return nil;
}

#if ON_ACTIVE_LOAD
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self registerObservers];
    }
    return self;
}
#endif

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

- (void)setImage:(UIImage *)image
            fade:(BOOL)fade
       matchSize:(BOOL)matchSize {

    if (matchSize &&
        (image.size.width != self.frame.size.width ||
         image.size.height != self.frame.size.height)) {
        image = [UIImage scaleImage:image maxSize:MAX(self.frame.size.width, self.frame.size.height)];
    }
    
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
 
        __weak BlockImageView *weak_self = self;
        
        [UIView animateWithDuration:0.4 animations:^{
            weak_self.fadeImageView.alpha = 1.f;
        } completion:^(BOOL finished) {
            // There were crashes due to an animation reference was invalid
            // This is a speculative fix for that. 
            if (weak_self) {
                weak_self.image = image;
                weak_self.fadeImageView.image = nil;
                [weak_self.fadeImageView removeFromSuperview];
            }
        }];
    }
    
}

- (void)setImage:(UIImage *)image
            fade:(BOOL)fade {
    [self setImage:image
              fade:fade
         matchSize:self.matchSize];
}

- (void)loadImageFromUrlString:(NSString *)urlString {
    self.imageUrl = urlString;
#if ON_ACTIVE_LOAD
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        return;
    }
#endif
    
    CGFloat white = 0.f;
    [self.backgroundColor getWhite:&white alpha:nil];
    
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:white > 0.5 ? UIActivityIndicatorViewStyleGray : UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.loadingIndicator];
    [self.loadingIndicator startAnimating];
    self.loadingIndicator.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2) ;
    
#if CACHE
    id cachedResult = nil;
    cachedResult = [[GlobalCache shared] imageForPath:urlString];
    if (cachedResult) {
        [self setImage:cachedResult fade:NO];
        return;
    }
#endif
    
    [self.imageConnection cancelAndClear];
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
        [[GlobalCache shared] setImage:
         self.matchSize ?
         [UIImage scaleImage:c.dataObject maxSize:[[UIScreen mainScreen] scale] * MAX(self.frame.size.width, self.frame.size.height)] :
         c.dataObject
                               forPath:c.urlString];
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


#pragma mark - Observers
#if ON_ACTIVE_LOAD
- (void)applicationDidBecomeActive {
    if (self.imageUrl.length > 0) {
        [self loadImage];
    }
}

- (void)applicationWillResignActive {
    [self.imageConnection cancelAndClear];
}

- (void)unregisterObservers {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
}

- (void)registerObservers {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidBecomeActive)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillResignActive)
     name:UIApplicationWillResignActiveNotification
     object:nil];
}
#endif

@end
