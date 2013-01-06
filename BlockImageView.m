//
//  BlockImageView.m
//  nearbyFriends
//
//  Created by jan on 11/20/12.
//  Copyright (c) 2012 in4mation GmbH. All rights reserved.
//

#define CACHE 1

#import "BlockImageView.h"
#import "DataConnection.h"

#if CACHE
#import "GlobalCache.h"
#endif

@interface BlockImageView ()
@property (nonatomic) DataConnection *imageConnection;
@property (nonatomic) UIImageView *fadeImageView;
@end

@implementation BlockImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.fadeImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    return self;
}

- (void)setImage:(UIImage *)image fade:(BOOL)fade {
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
    id cachedResult = nil;
#if CACHE
    cachedResult = [[GlobalCache shared] imageForPath:urlString];
#endif 
    if (cachedResult != nil) {
        [self setImage:cachedResult fade:NO];
        return;
    }
    
    self.imageConnection = [DataConnection withURLString:urlString];
    self.imageConnection.dataBlock = ^UIImage *(NSData *d) {
        return [UIImage imageWithData:d];
    };
    __weak BlockImageView *weak_self = self;
    self.imageConnection.completionBlock = ^(DataConnection *c){
        [weak_self setImage:c.dataObject fade:YES];
#if CACHE
        [[GlobalCache shared] setData:c.connectionData forPath:c.urlString];
        [[GlobalCache shared] setImage:c.dataObject forPath:c.urlString];
#endif
    };
    [self.imageConnection start];
}

- (void)prepareForReuse {
    self.image = nil;
    self.fadeImageView.image = nil;
    [self.fadeImageView removeFromSuperview];
    [self.imageConnection cancelAndClear];
}


@end
