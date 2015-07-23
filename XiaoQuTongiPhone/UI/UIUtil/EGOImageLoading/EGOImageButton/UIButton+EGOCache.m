//
//  UIButton+EGOCache.m
//  JU
//
//  Created by zeha fu on 12-4-29.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//


//
//  UIImageView+EGOCache.m
//  JU
//
//  Created by zeha fu on 12-4-29.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

//
//  UIImageView+EGOCache.m
//  JU
//
//  Created by zeha fu on 12-4-29.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import "UIButton+EGOCache.h"
#import "JULog.h"
#import "DDProgressView.h"
#import "TaobaoTFS.h"
#import "QuartzCore/QuartzCore.h"

@implementation UIButton (EGOCache)

- (void) initIndicator:(BOOL) usingIndicator {
    if (usingIndicator) {
        DDProgressView *progressView = (DDProgressView*)[self viewWithTag:kImageProgressView];
        if (!progressView) {
            progressView = [[DDProgressView alloc] init];
            [self addSubview:progressView];
            [progressView release];
        } 
        CGRect progressRect = CGRectMake(10, (self.frame.size.height / 2) - 5, self.frame.size.width - 20, 10);
        [progressView setFrame:progressRect];
        
        [progressView setOuterColor: [UIColor grayColor]] ;
        [progressView setInnerColor: [UIColor lightGrayColor]] ;
        
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        progressView.tag = kImageProgressView;
        progressView.hidden = NO;
        progressView.progress = 0;
    } else {
        [self removeIndicator];
    }
}

- (void) removeIndicator {
    DDProgressView* progressView = (DDProgressView*)[self viewWithTag:kImageProgressView];
    if (progressView) {
        [progressView removeFromSuperview];
    }
}

- (void)loadImageURL:(NSURL *)aURL placeHolderImage:(UIImage*)placeholderImage usingIndicator:(BOOL)usingIndicator delay:(float)delay {
  	[[EGOImageLoader sharedImageLoader] removeObserver:self];
    [self cancelImageLoad];
    
	UIImage* anImage = nil;
    anImage = [[EGOImageLoader sharedImageLoader] imageForURL:aURL shouldLoadWithObserver:self];
    
    //    SEL loadImageSEL = NSSelectorFromString(@"imageForURL:shouldLoadWithObserver:");
    //    NSInvocation* imageLoaderInvocation = [NSInvocation invocationWithMethodSignature:[EGOImageLoader instanceMethodSignatureForSelector:loadImageSEL]];
    //    [imageLoaderInvocation setSelector:loadImageSEL];
    //    [imageLoaderInvocation setTarget:[EGOImageLoader sharedImageLoader]];
    //    [imageLoaderInvocation setArgument:&aURL atIndex:2];
    //    [imageLoaderInvocation setArgument:&self atIndex:3];
    //    [imageLoaderInvocation retainArguments];
    //    [imageLoaderInvocation performSelector:@selector(invoke) withObject:nil afterDelay:0 inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
	
	if(anImage) {
        //延缓缓存图片读取
		[self setImage:anImage forState:UIControlStateNormal];
        [self setImage:nil forState:UIControlStateHighlighted];
        [self setImage:nil forState:UIControlStateSelected];
        
        [self initIndicator:NO];
	} else {
        if (delay != 0 && usingIndicator) {
            [self performSelector:@selector(initIndicator:) withObject:[NSNumber numberWithBool:usingIndicator] afterDelay:delay]; 
        } else if (delay == 0 && usingIndicator) {
            [self initIndicator:usingIndicator];
        }
        [self setImage:placeholderImage forState:UIControlStateNormal];
        [self setImage:nil forState:UIControlStateHighlighted];
        [self setImage:nil forState:UIControlStateSelected];
	}
}

- (void) loadImageURLs:(NSArray*) urls placeHolderImage:(UIImage*) placeHolderImage usingIndicator:(BOOL) usingIndicator delay:(float)delay {
    [[EGOImageLoader sharedImageLoader] removeObserver:self];
    [self cancelImageLoad];
    
    UIImage* image = nil;
    for (int i = 0; i < [urls count]; i++) {
        NSURL* url = [urls objectAtIndex:i];
        if (i == [urls count] - 1) {
            image = [[EGOImageLoader sharedImageLoader] imageForURL:url shouldLoadWithObserver:self];
        } else {
            image = [[EGOImageLoader sharedImageLoader] imageFromCacheForURL:url];
        }
        if (image) {
            //延缓缓存图片读取
            [self setImage:nil forState:UIControlStateNormal];
            [self setImage:nil forState:UIControlStateHighlighted];
            [self setImage:nil forState:UIControlStateSelected];
            break;
        }
    }
    if (image == nil) {
        [self setImage:placeHolderImage forState:UIControlStateNormal];
        [self setImage:nil forState:UIControlStateHighlighted];
        [self setImage:nil forState:UIControlStateSelected];
        if (delay != 0 && usingIndicator) {
            [self performSelector:@selector(initIndicator:) withObject:[NSNumber numberWithBool:usingIndicator] afterDelay:delay];
        } else if (delay == 0 && usingIndicator) {
            [self initIndicator:usingIndicator];
        }
    } else {
        [self initIndicator:NO];
    }
}

#pragma mark -
#pragma mark Image loading

- (void)cancelImageLoad {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(initIndicator:) object:[NSNumber numberWithBool:YES]];
    
    [self removeIndicator];
    
    [[EGOImageLoader sharedImageLoader] removeObserver:self];
	[[EGOImageLoader sharedImageLoader] cancelLoadForDelegate:self];
}


- (void)imageLoaderDidLoad:(NSNotification*)notification {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(imageLoaderDidLoad:) withObject:notification waitUntilDone:NO];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(initIndicator:) object:[NSNumber numberWithBool:YES]];
    
    [self removeIndicator];
    
    //	if(![[[notification userInfo] objectForKey:@"imageURL"] isEqual:self.imageURL]) return;
    if (![[EGOImageLoader sharedImageLoader] isStillLoadingImageException:[[notification userInfo] objectForKey:@"imageURL"]]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    
    DDLogVerbose(@"finish imageloader for url %@",[[notification userInfo] objectForKey:@"imageURL"]);
    
	UIImage* anImage = [[notification userInfo] objectForKey:@"image"];
    if (anImage == nil) {
        DDLogVerbose(@"fail imageloader in nil for url %@",[[notification userInfo] objectForKey:@"imageURL"]);
    }
    
    [self setImage:anImage forState:UIControlStateNormal];
    [self setImage:nil forState:UIControlStateHighlighted];
    [self setImage:nil forState:UIControlStateSelected];
    
	[self setNeedsDisplay];
	[[EGOImageLoader sharedImageLoader] removeObserver:self];
}

- (void)imageLoaderDidFailToLoad:(NSNotification*)notification {
    DDLogVerbose(@"fail imageloader for url %@",[[notification userInfo] objectForKey:@"imageURL"]);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(initIndicator:) object:[NSNumber numberWithBool:YES]];
    
    [self removeIndicator];
    
	[[EGOImageLoader sharedImageLoader] removeObserver:self];
    
    NSString* originPath = [TaobaoTFS normalImagePathForSmallPath:[[[notification userInfo] objectForKey:@"imageURL"] absoluteString]];
    if (originPath != nil) {
#ifndef DAILY_MODE
        DDLogWarn(@"Can not load Image %@ , instead reload Origin Image %@",[[[notification userInfo] objectForKey:@"imageURL"] absoluteString],originPath);
#endif
        [self loadImageURL:[NSURL URLWithString:originPath] placeHolderImage:self.imageView.image usingIndicator:YES delay:3];
    }
    
}

- (void) imageLoaderDidReceiveProgress:(NSNotification *)notification {
    NSNumber* progress = [[notification userInfo] objectForKey:@"progress"];
    [self updateProgressView:progress];
}

- (void)updateProgressView:(NSNumber *)progress {
	if ([progress floatValue] > 0) {
		DDProgressView *progressView = (DDProgressView*)[self viewWithTag:kImageProgressView];
		if (progressView != nil) {
            CGRect progressRect = CGRectMake(10, (self.frame.size.height / 2) - 5, self.frame.size.width - 20, 10);
            [progressView setFrame:progressRect];
            [progressView setProgress:[progress floatValue]];
		}
	}
}

@end
