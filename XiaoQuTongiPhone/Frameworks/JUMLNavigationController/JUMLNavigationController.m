//
//  MLNavigationController.m
//  MultiLayerNavigation
//
//  Created by Feather Chan on 13-4-12.
//  Modify by duanshuai on 13-7-1.
//  Copyright (c) 2013年 Feather Chan. All rights reserved.
//

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]

#import "JUMLNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "JUSevenAdapter.h"
#import "UIImage+JoyMapsAdditions.h"


@interface JUMLNavigationController ()
{
    CGPoint startTouch;
    
    UIImageView *lastScreenShotView;
    UIView *blackMask;
    
    BOOL _animating;
    
    //push信号量
    BOOL _pushing;
}

@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) NSMutableArray *screenShotsList;
@property (nonatomic,assign) BOOL isMoving;


@end


@implementation JUMLNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.screenShotsList = [[NSMutableArray alloc]initWithCapacity:2];
        self.canDragBack = YES;
        
        self.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.screenShotsList = nil;
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    
    [super dealloc];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                action:@selector(paningGestureReceive:)];
    //    [recognizer delaysTouchesBegan];
	recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
}

// Because the huoyan "kkBarcodeViewController" was can not access by api invoker
// So, Just change it's layout dynamic
- (void)_changeHuoyanBarcodeControllerLayout:(UIViewController *)vc {
    Class clazz = NSClassFromString(@"kkBarcodeViewController");
    if (clazz != Nil) {
        if ([vc class] == clazz && [vc respondsToSelector:@selector(edgesForExtendedLayout)]) {
            vc.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
}


// override the push method
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (_pushing){
        return;
    }
    
    _pushing = YES;
    
    [self _changeHuoyanBarcodeControllerLayout:viewController];
	[self _pushScreenShot];
    
    if ([self.viewControllers count] > 0) {
        viewController.navigationItem.leftBarButtonItem = [self _adapterReturnButtonInViewController:viewController];
        
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:animated];
}

/**
 *  将当前view的
 */
-(void)_pushScreenShot{
    UIImage* image = [self _capture:[self _topVisibleView]];
	if (image) {
		[self.screenShotsList addObject:image];
	}
}

/**
 *  获得当前可见的最上层view
 *
 *  @return visible view
 */
-(UIView*)_topVisibleView{
    UIView *view = (self.tabBarController != nil) ? self.tabBarController.view : self.view;
    return view;
}


- (UIBarButtonItem *)_adapterReturnButtonInViewController:(UIViewController *)viewController{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setShowsTouchWhenHighlighted:YES];
    button.bounds = CGRectMake(0, 0, 20, 20);
    [button setBackgroundImage:[UIImage imageNamed:@"navigation_back_icon"] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(_doBack:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)_doBack:(id)sender {
    UIViewController *tvc = self.topViewController;
    if ([tvc respondsToSelector:@selector(back:)]) {
        [tvc performSelector:@selector(back:) withObject:sender];
        
    } else if ([tvc respondsToSelector:@selector(pressBack:)]) {
        [tvc performSelector:@selector(pressBack:) withObject:sender];
        
    } else {
        [self popViewControllerAnimated:YES];
    }
}

// override the pop method
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	[self.screenShotsList removeLastObject];
	return [super popViewControllerAnimated:animated];
}

- (void) rawPopViewControllerAnimated:(BOOL)animated {
	UIViewController *tvc = self.topViewController;
    
    if (_pushing){
        return;
    }
    
    _pushing = YES;

    
	if ([tvc respondsToSelector:@selector(back:)]) {
        [UIView setAnimationsEnabled:NO];
        [tvc performSelector:@selector(back:) withObject:@"JUMLNavigationController"];
        [UIView setAnimationsEnabled:YES];
        
        return;
        
    } else if ([tvc respondsToSelector:@selector(pressBack:)]) {
        [UIView setAnimationsEnabled:NO];
        [tvc performSelector:@selector(pressBack:) withObject:@"JUMLNavigationController"];
        [UIView setAnimationsEnabled:YES];
        
        return;
    }
	
	[self popViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
	NSArray* popedViewControllers = [super popToViewController:viewController animated:animated];
	
	for (UIViewController* viewController in popedViewControllers) {
		[self.screenShotsList removeLastObject];
	}
	
	return popedViewControllers;
}

#pragma mark - Utility Methods -

// get the current view screen shot
- (UIImage *)_capture:(UIView*)view {
    UIImage *image = [UIImage imageWithSize:view.bounds.size
                               drawingBlock:^(CGContextRef context, CGRect rect){
                                   if ([UIDynamicAnimator class] != Nil) {
                                       // for iOS 7
                                       [view drawViewHierarchyInRect:rect afterScreenUpdates:NO];
                                       
                                   } else {
                                       [view.layer renderInContext:context];
                                   }
                               }];
    
    return image;
}

// set lastScreenShotView 's position and alpha when paning
- (void)moveViewWithX:(float)x
{
    x = x>320?320:x;
    x = x<0?0:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    float scale = (x/6400)+0.95;
    float alpha = 0.4 - (x/800);
    
    lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    blackMask.alpha = alpha;
    
}

#pragma mark - Gesture Recognizer -

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	if (self.viewControllers.count <= 1 || !self.canDragBack || _animating) return NO;
	return YES;
}

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    // If the viewControllers has only one vc or disable the interaction, then return.
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    // we get the touch position by the window's coordinate
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    // begin paning, show the backgroundView(last screenshot),if not exist, create it.
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        [self.view endEditing:YES];
        
        _isMoving = YES;
        startTouch = touchPoint;
        
        if (!self.backgroundView)
        {
            CGRect frame = self.view.frame;
            
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:blackMask];
        }
		
		if (!self.backgroundView.superview) {
			[self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
		}
        
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
        
        //End paning, always check that if it should move right or move left automatically
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        
        if (touchPoint.x - startTouch.x > 50)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:320];
            } completion:^(BOOL finished) {
                
                [self rawPopViewControllerAnimated:NO];
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                
                _isMoving = NO;
                self.backgroundView.hidden = YES; // bugfix 2013.7.4 Zxing background problem
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
            
        }
        return;
        
        // cancal panning, alway move to left side automatically
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        
        return;
    }
    
    // it keeps move with touch
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}

#pragma mark - navigation controller delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    _animating = animated;
    _pushing = YES;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    _animating = NO;
    _pushing = NO;
}

@end

