//
//  UIImageView+EGOCache.m
//  JU
//
//  Created by zeha fu on 12-4-29.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import "UIImageView+EGOCache.h"
#import "JULog.h"
#import "DDProgressView.h"
#import "TaobaoTFS.h"
#import "QuartzCore/QuartzCore.h"
#import "EGOCache.h"

@implementation UIImageView (EGOCache)
@dynamic delegate ;

- (void) initIndicator:(BOOL) usingIndicator {
    if (usingIndicator) {
        DDProgressView *progressView = (DDProgressView*)[self viewWithTag:kImageProgressView];
        if (!progressView) {
            progressView = [[DDProgressView alloc] init];
            [self addSubview:progressView];
            [progressView release];
        } 
        CGRect progressRect = CGRectMake(self.frame.size.width / 4, (self.frame.size.height / 2) + (self.frame.size.height / 12), self.frame.size.width / 2, 10);
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
    
    [self retain];
    
    [self cancelImageLoad];
	[[EGOImageLoader sharedImageLoader] removeObserver:self];
    
    if (placeholderImage != nil) {
        self.image = placeholderImage;
    } else {
        self.image = nil;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
//        UIImage* anImage = [[EGOImageLoader sharedImageLoader] imageForURL:aURL shouldLoadWithObserver:self];
        UIImage* anImage = [[EGOImageLoader sharedImageLoader] imageFromCacheForURL:aURL];
        
        //    SEL loadImageSEL = NSSelectorFromString(@"imageForURL:shouldLoadWithObserver:");
        //    NSInvocation* imageLoaderInvocation = [NSInvocation invocationWithMethodSignature:[EGOImageLoader instanceMethodSignatureForSelector:loadImageSEL]];
        //    [imageLoaderInvocation setSelector:loadImageSEL];
        //    [imageLoaderInvocation setTarget:[EGOImageLoader sharedImageLoader]];
        //    [imageLoaderInvocation setArgument:&aURL atIndex:2];
        //    [imageLoaderInvocation setArgument:&self atIndex:3];
        //    [imageLoaderInvocation retainArguments];
        //    [imageLoaderInvocation performSelector:@selector(invoke) withObject:nil afterDelay:0 inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(anImage) {
                //延缓缓存图片读取
                self.image = anImage;
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishLoadImage:)]) {
                    [self.delegate didFinishLoadImage:anImage];
                }
                
                [self initIndicator:NO];
            } else {
                [[EGOImageLoader sharedImageLoader] loadImageForURL:aURL withObserver:self];
                
                self.image = placeholderImage;
                if (delay != 0 && usingIndicator) {
                    [self performSelector:@selector(initIndicator:) withObject:[NSNumber numberWithBool:usingIndicator] afterDelay:delay];
                } else if (delay == 0 && usingIndicator) {
                    [self initIndicator:usingIndicator];
                }
            }
            
        });
    });
		
	[self release];
}

- (void) loadImageURLs:(NSArray*) urls placeHolderImage:(UIImage*) placeholderImage usingIndicator:(BOOL) usingIndicator delay:(float)delay {
    
    [self retain];
    
    [self cancelImageLoad];
	[[EGOImageLoader sharedImageLoader] removeObserver:self];
    
    if (placeholderImage != nil) {
        self.image = placeholderImage;
    } else {
        self.image = nil;
    }
    
    if ([urls count] == 0) {
        [self release];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        //        UIImage* anImage = [[EGOImageLoader sharedImageLoader] imageForURL:aURL shouldLoadWithObserver:self];
        UIImage* anImage = nil;
        
        for (int i = 0; i < [urls count]; i++) {
            NSURL* url = [urls objectAtIndex:i];
            anImage = [[EGOImageLoader sharedImageLoader] imageFromCacheForURL:url];
            
            if (anImage != nil) {
                break;
            }
        }
        
        //    SEL loadImageSEL = NSSelectorFromString(@"imageForURL:shouldLoadWithObserver:");
        //    NSInvocation* imageLoaderInvocation = [NSInvocation invocationWithMethodSignature:[EGOImageLoader instanceMethodSignatureForSelector:loadImageSEL]];
        //    [imageLoaderInvocation setSelector:loadImageSEL];
        //    [imageLoaderInvocation setTarget:[EGOImageLoader sharedImageLoader]];
        //    [imageLoaderInvocation setArgument:&aURL atIndex:2];
        //    [imageLoaderInvocation setArgument:&self atIndex:3];
        //    [imageLoaderInvocation retainArguments];
        //    [imageLoaderInvocation performSelector:@selector(invoke) withObject:nil afterDelay:0 inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(anImage) {
                //延缓缓存图片读取
                self.image = anImage;
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishLoadImage:)]) {
                    [self.delegate didFinishLoadImage:anImage];
                }
                
                [self initIndicator:NO];
            } else {
                [[EGOImageLoader sharedImageLoader] loadImageForURL:[urls objectAtIndex:[urls count]-1] withObserver:self];
                
                self.image = placeholderImage;
                if (delay != 0 && usingIndicator) {
                    [self performSelector:@selector(initIndicator:) withObject:[NSNumber numberWithBool:usingIndicator] afterDelay:delay];
                } else if (delay == 0 && usingIndicator) {
                    [self initIndicator:usingIndicator];
                }
            }
            
        });
    });
    
    [self release];
}

#pragma mark -
#pragma mark Image loading

- (void)cancelImageLoad {
    DDLogVerbose(@"cancel imageloader indexRow %i",self.tag);
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
    
    DDLogVerbose(@"finish imageloader for url %@ indexRow %i",[[notification userInfo] objectForKey:@"imageURL"],self.tag);
    
	UIImage* anImage = [[notification userInfo] objectForKey:@"image"];
    if (anImage == nil) {
        DDLogVerbose(@"fail imageloader in nil for url %@ indexRow %i",[[notification userInfo] objectForKey:@"imageURL"],self.tag);
    }
    
	self.image = anImage;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishLoadImage:)]) {
        [self.delegate didFinishLoadImage:anImage];
    }
    
	[self setNeedsDisplay];
	[[EGOImageLoader sharedImageLoader] removeObserver:self];
}

- (void)imageLoaderDidFailToLoad:(NSNotification*)notification {
    DDLogVerbose(@"fail imageloader for url %@ indexRow %i",[[notification userInfo] objectForKey:@"imageURL"],self.tag);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(initIndicator:) object:[NSNumber numberWithBool:YES]];
    
    [self removeIndicator];
    
	[[EGOImageLoader sharedImageLoader] removeObserver:self];
    
    NSString* originPath = [TaobaoTFS normalImagePathForSmallPath:[[[notification userInfo] objectForKey:@"imageURL"] absoluteString]];
    if (originPath != nil) {
#ifndef DAILY_MODE
        DDLogWarn(@"Can not load Image %@ , instead reload Origin Image %@  indexRow %i",[[[notification userInfo] objectForKey:@"imageURL"] absoluteString],originPath,self.tag);
#endif
        [self loadImageURL:[NSURL URLWithString:originPath] placeHolderImage:self.image usingIndicator:YES delay:0];
    } else {
        self.image = nil;
#pragma - mark default image
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailLoadImage)]) {
        [self.delegate didFailLoadImage];
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
            CGRect progressRect = CGRectMake(self.frame.size.width / 4, (self.frame.size.height / 2) + (self.frame.size.height / 12), self.frame.size.width / 2, 10);
            [progressView setFrame:progressRect];
            [progressView setProgress:[progress floatValue]];
		}
	}
}

// 使用Delegate需要UIImageView覆盖delegate 设置函数
- (id<UIImageLoaderEGOCacheDelegate>) delegate {
    return nil;
}

- (void) setDelegate:(id<UIImageLoaderEGOCacheDelegate>)m_delegate {
    
}

@end
