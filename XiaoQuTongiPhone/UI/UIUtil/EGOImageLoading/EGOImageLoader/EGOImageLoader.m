//
//  EGOImageLoader.m
//  EGOImageLoading
//
//  Created by Shaun Harrison on 9/15/09.
//  Copyright (c) 2009-2010 enormego
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGOImageLoader.h"
#import "EGOImageLoadConnection.h"
#import "EGOCache.h"
#import "JULog.h"
#import "DeviceDetect.h"

#define MAX_SYNC_IMAGE_LOADING 5
#define LOADING_IMAGE_DELAY 0.1

static EGOImageLoader* __imageLoader;

inline static NSString* keyForURL(NSURL* url, NSString* style) {
	if(style) {
		return [NSString stringWithFormat:@"ImageLoader-%u-%u", [[url description] hash], [style hash]];
	} else {
		return [NSString stringWithFormat:@"ImageLoader-%u", [[url description] hash]];
	}
}

#if __EGOIL_USE_BLOCKS
	#define kNoStyle @"ImageLoader-nostyle"
	#define kCompletionsKey @"completions"
	#define kStylerKey @"styler"
	#define kStylerQueue _operationQueue
	#define kCompletionsQueue dispatch_get_main_queue()
#endif

#if __EGOIL_USE_NOTIF
	#define kImageNotificationLoaded(s) [@"kImageLoaderNotificationLoaded-" stringByAppendingString:keyForURL(s, nil)]
	#define kImageNotificationLoadFailed(s) [@"kImageLoaderNotificationLoadFailed-" stringByAppendingString:keyForURL(s, nil)]
    #define kImageNotificationLoadProgress(s) [@"kImageLoaderNotificationLoadProgress-" stringByAppendingString:keyForURL(s, nil)]
#endif

@interface EGOImageLoader ()
#if __EGOIL_USE_BLOCKS
- (void)handleCompletionsForConnection:(EGOImageLoadConnection*)connection image:(UIImage*)image error:(NSError*)error;
#endif
@end

@implementation EGOImageLoader
@synthesize currentConnections=_currentConnections;
@synthesize lazyConnections = _lazyConnections;
@synthesize cacheDelegates = _cacheDelegates;
@synthesize cacheURLs = _cacheURLs;

+ (EGOImageLoader*)sharedImageLoader {
	@synchronized(self) {
		if(!__imageLoader) {
			__imageLoader = [[[self class] alloc] init];
            __imageLoader.cacheDelegates = [[[NSMutableArray alloc]init] autorelease];
            __imageLoader.cacheURLs = [[[NSMutableArray alloc]init] autorelease];
		}
	}
	
	return __imageLoader;
}

- (void) setLazyURLs:(NSMutableArray*) imageURLs {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSMutableDictionary* lazyConnections = [[[NSMutableDictionary alloc]init] autorelease];
        
        EGOImageLoadConnection* connection;
        
        for (NSURL* aURL in imageURLs) {
            if(![[EGOCache currentCache] hasCacheForKey:keyForURL(aURL,nil)]) {
                connection = [[[EGOImageLoadConnection alloc] initWithImageURL:aURL delegate:self] autorelease];
                [lazyConnections setObject:connection forKey:aURL];
            }
        }
        
        if ([lazyConnections count] != 0) {
            [self loadLazyConnections:lazyConnections];
        }
        
    });
}

- (void) loadLazyConnections:(NSMutableDictionary *)lazyConnections {
    
    if (_lazyConnections == nil) {
        _lazyConnections = [[NSMutableDictionary alloc]init];
    }
    
    for (EGOImageLoadConnection* conn in [_lazyConnections allValues]) {
        if (![conn isStart]) {
            [self cleanUpConnection:conn];
        }
    }

    [self.lazyConnections addEntriesFromDictionary:lazyConnections];
    
    if ([self.currentConnections count] == 0) {
        if ([self.lazyConnections count] > 0) {
            EGOImageLoadConnection* nextConn = [[self.lazyConnections allValues] objectAtIndex:0];
            if (nextConn && ![nextConn isStart]) {
                if ([DeviceDetect isLowPerformenceDevice]) {
                    [nextConn performSelector:@selector(start) withObject:nil afterDelay:LOADING_IMAGE_DELAY];
                } else {
                    [nextConn performSelector:@selector(start) withObject:nil];
                }
            }
        }
    }
}

- (id)init {
	if((self = [super init])) {
		connectionsLock = [[NSLock alloc] init];
        delegateLock = [[NSLock alloc]init];
		currentConnections = [[NSMutableDictionary alloc] init];
		
		#if __EGOIL_USE_BLOCKS
		_operationQueue = dispatch_queue_create("com.enormego.EGOImageLoader",NULL);
		dispatch_queue_t priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
		dispatch_set_target_queue(priority, _operationQueue);
		#endif
	}
	
	return self;
}

- (EGOImageLoadConnection*)loadingConnectionForURL:(NSURL*)aURL {
	EGOImageLoadConnection* connection = [[self.currentConnections objectForKey:aURL] retain];
	if(!connection) return nil;
	else return [connection autorelease];
}


- (void)cleanUpConnection:(EGOImageLoadConnection*)connection {
	if(!connection.imageURL) return;
	
    [[connection retain] autorelease];
    
	connection.delegate = nil;
	
	[connectionsLock lock];
    
	[currentConnections removeObjectForKey:connection.imageURL];
	self.currentConnections = [[currentConnections copy] autorelease];
    
    [_lazyConnections removeObjectForKey:connection.imageURL];
    
	[connectionsLock unlock];	
    
    int i = 0;
    for (id aUrl in [self.currentConnections allKeys]) {
        if (i < MAX_SYNC_IMAGE_LOADING) {
            EGOImageLoadConnection* nextConn = [self.currentConnections objectForKey:aUrl];
            if (nextConn && ![nextConn isStart]) {
                if ([DeviceDetect isLowPerformenceDevice]) {
                    [nextConn performSelector:@selector(start) withObject:nil afterDelay:LOADING_IMAGE_DELAY];
                } else {
                    [nextConn performSelector:@selector(start) withObject:nil];
                }
                i++;
            }
        }
    }
    
    if ([self.currentConnections count] == 0) {
        if ([self.lazyConnections count] > 0) {
            EGOImageLoadConnection* nextConn = [[self.lazyConnections allValues] objectAtIndex:0];
            if (nextConn && ![nextConn isStart]) {
                if ([DeviceDetect isLowPerformenceDevice]) {
                    [nextConn performSelector:@selector(start) withObject:nil afterDelay:LOADING_IMAGE_DELAY];
                } else {
                    [nextConn performSelector:@selector(start) withObject:nil];
                }
            }
        }
    }
}


- (void) cancelAllConnections {
    
    for (id aUrl in [self.currentConnections allKeys]) {
        EGOImageLoadConnection* connection = [self.currentConnections objectForKey:aUrl];
        if (connection) {
            [connection cancel];
            
#if __EGOIL_USE_NOTIF
            NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoadFailed(connection.imageURL)
                                                                         object:self
                                                                       userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"user Cancel",@"error",connection.imageURL,@"imageURL",nil]];
            
            [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
#endif
            
#if __EGOIL_USE_BLOCKS
            [self handleCompletionsForConnection:connection image:nil error:@"user Cancel"];
#endif
            
            [self removeDelegateForURL:connection.imageURL];
            
            connection.delegate = nil;
        }
    }
    
    self.currentConnections = [[[NSMutableDictionary alloc]init] autorelease];
}


- (void)clearCacheForURL:(NSURL*)aURL {
	[self clearCacheForURL:aURL style:nil];
}

- (void)clearCacheForURL:(NSURL*)aURL style:(NSString*)style {
	[[EGOCache currentCache] removeCacheForKey:keyForURL(aURL, style)];
}

- (BOOL)isLoadingImageURL:(NSURL*)aURL {
	return [self loadingConnectionForURL:aURL] ? YES : NO;
}

- (BOOL) isStillLoadingImageException:(NSURL*)aURL {
    if ([[self.currentConnections allKeys] count] == 0) {
        return NO;
    } else if ([[self.currentConnections allKeys] count] == 1) {
        return ![self isLoadingImageURL:aURL];
    } else {
        return YES;
    }
}

- (void)cancelLoadForURL:(NSURL*)aURL {
	EGOImageLoadConnection* connection = [self loadingConnectionForURL:aURL];
    DDLogVerbose(@"conneciton indicator %@",connection);
	[NSObject cancelPreviousPerformRequestsWithTarget:connection selector:@selector(start) object:nil];
    
//    [self removeDelegateForURL:connection.imageURL];
//    
//	[connection cancel];
//	[self cleanUpConnection:connection];
    
    BOOL exsit = [self removeDelegateForURL:connection.imageURL];
    if (!exsit) {
        [connection cancel];
        [self cleanUpConnection:connection];     
    }
}

- (EGOImageLoadConnection*)loadImageForURL:(NSURL*)aURL {
	EGOImageLoadConnection* connection;
	

	if((connection = [self loadingConnectionForURL:aURL])) {
		return connection;
	} else {
		connection = [[[EGOImageLoadConnection alloc] initWithImageURL:aURL delegate:self] autorelease];
	
		[connectionsLock lock];
        
		[currentConnections setObject:connection forKey:aURL];
		self.currentConnections = [[currentConnections copy] autorelease];
        
		[connectionsLock unlock];
        
        if ([self.currentConnections count] <= MAX_SYNC_IMAGE_LOADING) {
            if ([DeviceDetect isLowPerformenceDevice]) {
                [connection performSelector:@selector(start) withObject:nil afterDelay:LOADING_IMAGE_DELAY];
            } else {
                [connection performSelector:@selector(start) withObject:nil];
            }
        }
        

#ifdef DEBUG
        int i = 0;
        for (id aUrl in [self.currentConnections allKeys]) {
            EGOImageLoadConnection* nextConn = [self.currentConnections objectForKey:aUrl];
            if ([nextConn isStart]) {
                i++;
            }
        }
        DDLogVerbose(@"current Loading Image Count: %i",i);
#endif
		
		return connection;
	}
}

#if __EGOIL_USE_NOTIF
- (void)loadImageForURL:(NSURL*)aURL observer:(id<EGOImageLoaderObserver>)observer {
	if(!aURL) return;
    
	if([observer respondsToSelector:@selector(imageLoaderDidLoad:)]) {
		[[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(imageLoaderDidLoad:) name:kImageNotificationLoaded(aURL) object:self];
	}
    
    DDLogVerbose(@"url %@ key %@",aURL,kImageNotificationLoaded(aURL));
	
	if([observer respondsToSelector:@selector(imageLoaderDidFailToLoad:)]) {
		[[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(imageLoaderDidFailToLoad:) name:kImageNotificationLoadFailed(aURL) object:self];
	}
    
    if([observer respondsToSelector:@selector(imageLoaderDidReceiveProgress:)]) {
		[[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(imageLoaderDidReceiveProgress:) name:kImageNotificationLoadProgress(aURL) object:self];
	}

	[self loadImageForURL:aURL];
}

- (UIImage*)imageForURL:(NSURL*)aURL shouldLoadWithObserver:(id<EGOImageLoaderObserver>)observer {
	if(!aURL) return nil;
	
	UIImage* anImage = [[EGOCache currentCache] imageForKey:keyForURL(aURL,nil)];
	
	if(anImage) {
        DDLogVerbose(@"Get The Image From Cache :%@",aURL);
        
#pragma mark delay set Image improve performance
//        if([observer respondsToSelector:@selector(imageLoaderDidLoad:)]) {
//            [[NSNotificationCenter defaultCenter] addObserver:observer selector:@selector(imageLoaderDidLoad:) name:kImageNotificationLoaded(aURL) object:self];
//        }
//        
//        NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoaded(aURL)
//																	 object:self
//																   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:anImage,@"image",aURL,@"imageURL",nil]];
//		
//		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
        
		return anImage;
	} else {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        DDLogVerbose(@"start imageloader for url %@",aURL);
        
        [_cacheDelegates addObject:observer];
        [_cacheURLs addObject:aURL];
		[self loadImageForURL:aURL observer:observer];
        
		return nil;
	}
}

- (void) loadImageForURL:(NSURL*)aURL withObserver:(id<EGOImageLoaderObserver>)observer {
	if(!aURL) return;
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    DDLogVerbose(@"start imageloader for url %@",aURL);
    
    [_cacheDelegates addObject:observer];
    [_cacheURLs addObject:aURL];
    [self loadImageForURL:aURL observer:observer];
    
}

- (UIImage*)imageFromCacheForURL:(NSURL*)aURL {
	if(!aURL) return nil;
	
	UIImage* anImage = [[EGOCache currentCache] imageForKey:keyForURL(aURL,nil)];
	
    if (anImage) {
        DDLogVerbose(@"Get The Image From Cache :%@",aURL);
    }
    
    return anImage;
}

- (void) saveImageData:(NSData*)data forURL:(NSURL*)aURL {
    //默认保存7天
    [[EGOCache currentCache] setData:data forKey:keyForURL(aURL,nil) withTimeoutInterval:604800];
}

- (UIImage*)imageFromCacheForURLs:(NSArray*)urls {
	if(!urls && [urls count] != 0) return nil;
	for (NSURL* aURL in urls) {
        UIImage* anImage = [[EGOCache currentCache] imageForKey:keyForURL(aURL,nil)];
        
        if (anImage) {
            DDLogVerbose(@"Get The Image From Cache :%@",aURL);
            return anImage;
        }
    }
	return nil;
}

- (void)removeObserver:(id<EGOImageLoaderObserver>)observer {
	[[NSNotificationCenter defaultCenter] removeObserver:observer name:nil object:self];
}

- (void)removeObserver:(id<EGOImageLoaderObserver>)observer forURL:(NSURL*)aURL {
	[[NSNotificationCenter defaultCenter] removeObserver:observer name:kImageNotificationLoaded(aURL) object:self];
	[[NSNotificationCenter defaultCenter] removeObserver:observer name:kImageNotificationLoadFailed(aURL) object:self];
}

#endif

#if __EGOIL_USE_BLOCKS
- (void)loadImageForURL:(NSURL*)aURL completion:(void (^)(UIImage* image, NSURL* imageURL, NSError* error))completion {
	[self loadImageForURL:aURL style:nil styler:nil completion:completion];
}

- (void)loadImageForURL:(NSURL*)aURL style:(NSString*)style styler:(UIImage* (^)(UIImage* image))styler completion:(void (^)(UIImage* image, NSURL* imageURL, NSError* error))completion {
	UIImage* anImage = [[EGOCache currentCache] imageForKey:keyForURL(aURL,style)];

	if(anImage) {
		completion(anImage, aURL, nil);
	} else if(!anImage && styler && style && (anImage = [[EGOCache currentCache] imageForKey:keyForURL(aURL,nil)])) {
		dispatch_async(kStylerQueue, ^{
			UIImage* image = styler(anImage);
			[[EGOCache currentCache] setImage:image forKey:keyForURL(aURL, style) withTimeoutInterval:604800];
			dispatch_async(kCompletionsQueue, ^{
				completion(image, aURL, nil);
			});
		});
	} else {
		EGOImageLoadConnection* connection = [self loadImageForURL:aURL];
		void (^completionCopy)(UIImage* image, NSURL* imageURL, NSError* error) = [completion copy];
		
		NSString* handlerKey = style ? style : kNoStyle;
		NSMutableDictionary* handler = [connection.handlers objectForKey:handlerKey];
		
		if(!handler) {
			handler = [[NSMutableDictionary alloc] initWithCapacity:2];
			[connection.handlers setObject:handler forKey:handlerKey];

			[handler setObject:[NSMutableArray arrayWithCapacity:1] forKey:kCompletionsKey];
			if(styler) {
				UIImage* (^stylerCopy)(UIImage* image) = [styler copy];
				[handler setObject:stylerCopy forKey:kStylerKey];
				[stylerCopy release];
			}
			
			[handler release];
		}
		
		[[handler objectForKey:kCompletionsKey] addObject:completionCopy];
		[completionCopy release];
	}
}
#endif

- (BOOL)hasLoadedImageURL:(NSURL*)aURL {
	return [[EGOCache currentCache] hasCacheForKey:keyForURL(aURL,nil)];
}

- (NSUInteger)indexOfWaitingForURL:(NSURL *)url
{
    // Do a linear search, simple (even if inefficient)
    NSUInteger idx;
    for (idx = 0; idx < [_cacheURLs count]; idx++)
    {
//        [_cacheURLs indexOfObjectIdenticalTo:url];
        if ([[_cacheURLs objectAtIndex:idx] isEqual:url])
        {
            return idx;
        }
    }
    return NSNotFound;
}

- (NSUInteger) indexOfDelegate:(id<EGOImageLoaderObserver>) delegate {
    // Do a linear search, simple (even if inefficient)
    NSUInteger idx;
    for (idx = 0; idx < [_cacheDelegates count]; idx++)
    {
        if ([_cacheDelegates objectAtIndex:idx] == delegate)
        {
            return idx;
        }
    }
    return NSNotFound;
}

- (BOOL) removeDelegateForURL:(NSURL *) url {
    if (url == nil) {
        return NO;
    }
    [url retain];
    
    
    
    [delegateLock lock];
    
    id delegate = nil;
    NSUInteger idx = [_cacheURLs indexOfObjectIdenticalTo:url];
    if ([_cacheDelegates count] > idx && [_cacheURLs count] > idx) {
        if ([_cacheDelegates count] != 0 && [_cacheURLs count] != 0) {
            delegate = [[_cacheDelegates objectAtIndex:idx] retain];
            [_cacheDelegates removeObjectAtIndex:idx];        
            [_cacheURLs removeObjectAtIndex:idx];   
        }    
    }
    
    [delegateLock unlock];
    
    if ([_cacheURLs containsObject:url]) {
        [delegate release];
        [url release];
        return YES;
    }

    [delegate release];    
    [url release];
    return NO;
}

- (void) cancelLoadForDelegate:(id<EGOImageLoaderObserver>) delegate {
    NSUInteger idx = [self indexOfDelegate:delegate];
    if (idx == NSNotFound) {
        return;
    } else {
        EGOImageLoadConnection* connection = [self loadingConnectionForURL:[_cacheURLs objectAtIndex:idx]];
        
        DDLogVerbose(@"cancel imageloader for url %@",[_cacheURLs objectAtIndex:idx]);
        [NSObject cancelPreviousPerformRequestsWithTarget:connection selector:@selector(start) object:nil];

        [self removeObserver:delegate forURL:[_cacheURLs objectAtIndex:idx]];
        BOOL exsit = [self removeDelegateForURL:[_cacheURLs objectAtIndex:idx]];
        if (!exsit) {
            [connection cancel];
            [self cleanUpConnection:connection];     
        }
    }
}


#pragma mark -
#pragma mark URL Connection delegate methods

- (void)imageLoadConnection:(EGOImageLoadConnection *)connection didReceiveData:(NSData *)data {
    [connection retain];
    // Notify all the delegates with this downloader
    NSNumber *progress = [NSNumber numberWithFloat:(connection.totalReceivedLength / connection.expectedContentLength)];
#if __EGOIL_USE_NOTIF
    NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoadProgress(connection.imageURL)
                                                                 object:self
                                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:progress,@"progress",connection.imageURL,@"imageURL",nil]];
    
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
#endif
    
	[connection release];
}

- (void)imageLoadConnectionDidFinishLoading:(EGOImageLoadConnection *)connection {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        UIImage* anImage = [UIImage imageWithData:connection.responseData];
        
        DDLogVerbose(@"length: %i for url: %@",connection.responseData.length,connection.imageURL);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(!anImage || [connection.responseData length] < 100) {
                NSError* error = [NSError errorWithDomain:[connection.imageURL host] code:406 userInfo:nil];
                
#if __EGOIL_USE_NOTIF
                NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoadFailed(connection.imageURL)
                                                                             object:self
                                                                           userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error,@"error",connection.imageURL,@"imageURL",nil]];
                
                [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
#endif
                
#if __EGOIL_USE_BLOCKS
                [self handleCompletionsForConnection:connection image:nil error:error];
#endif
            } else {
                // 默认保存时间是7天
                [[EGOCache currentCache] setData:connection.responseData forKey:keyForURL(connection.imageURL,nil) withTimeoutInterval:604800];
                
                [currentConnections removeObjectForKey:connection.imageURL];
                self.currentConnections = [[currentConnections copy] autorelease];
                
#if __EGOIL_USE_NOTIF
                NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoaded(connection.imageURL)
                                                                             object:self
                                                                           userInfo:[NSDictionary dictionaryWithObjectsAndKeys:anImage,@"image",connection.imageURL,@"imageURL",nil]];
                
                [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
#endif
                
#if __EGOIL_USE_BLOCKS
                [self handleCompletionsForConnection:connection image:anImage error:nil];
#endif
            }
            
            [self removeDelegateForURL:connection.imageURL];
            
            [self cleanUpConnection:connection];

        });
                    
    });
	       

}

- (void)imageLoadConnection:(EGOImageLoadConnection *)connection didFailWithError:(NSError *)error {
	[currentConnections removeObjectForKey:connection.imageURL];
	self.currentConnections = [[currentConnections copy] autorelease];
	
	#if __EGOIL_USE_NOTIF
	NSNotification* notification = [NSNotification notificationWithName:kImageNotificationLoadFailed(connection.imageURL)
																 object:self
															   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error,@"error",connection.imageURL,@"imageURL",nil]];
	
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
	#endif
	
	#if __EGOIL_USE_BLOCKS
	[self handleCompletionsForConnection:connection image:nil error:error];
	#endif
    
    [self removeDelegateForURL:connection.imageURL];

	[self cleanUpConnection:connection];
}

#if __EGOIL_USE_BLOCKS
- (void)handleCompletionsForConnection:(EGOImageLoadConnection*)connection image:(UIImage*)image error:(NSError*)error {
	if([connection.handlers count] == 0) return;

	NSURL* imageURL = connection.imageURL;
	
	void (^callCompletions)(UIImage* anImage, NSArray* completions) = ^(UIImage* anImage, NSArray* completions) {
		dispatch_async(kCompletionsQueue, ^{
			for(void (^completion)(UIImage* image, NSURL* imageURL, NSError* error) in completions) {
				completion(anImage, connection.imageURL, error);
			}
		});
	};
	
	for(NSString* styleKey in connection.handlers) {
		NSDictionary* handler = [connection.handlers objectForKey:styleKey];
		UIImage* (^styler)(UIImage* image) = [handler objectForKey:kStylerKey];
		if(!error && image && styler) {
			dispatch_async(kStylerQueue, ^{
				UIImage* anImage = styler(image);
				[[EGOCache currentCache] setImage:anImage forKey:keyForURL(imageURL, styleKey) withTimeoutInterval:604800];
				callCompletions(anImage, [handler objectForKey:kCompletionsKey]);
			});
		} else {
			callCompletions(image, [handler objectForKey:kCompletionsKey]);
		}
	}
}
#endif

#pragma mark -

- (void)dealloc {
	#if __EGOIL_USE_BLOCKS
		dispatch_release(_operationQueue), _operationQueue = nil;
	#endif
	
	self.currentConnections = nil;
    self.lazyConnections = nil;
	[currentConnections release], currentConnections = nil;
	[connectionsLock release], connectionsLock = nil;
    RELEASE_SAFELY(delegateLock);
    self.cacheURLs = nil;
    self.cacheDelegates = nil;
	[super dealloc];
}

@end