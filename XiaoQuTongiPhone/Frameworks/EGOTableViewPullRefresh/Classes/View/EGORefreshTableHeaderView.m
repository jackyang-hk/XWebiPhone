//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
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

#import "EGORefreshTableHeaderView.h"


#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f

@interface EGORefreshTableHeaderView ()
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIColor *shadowColor;
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize canTriggerRefresh = _canTriggerRefresh;
@synthesize lastUpdatedLabel = _lastUpdatedLabel;
@synthesize statusLabel = _statusLabel;
@synthesize arrowImage = _arrowImage;
@synthesize activityView = _activityView;

@synthesize delegate = _delegate;
@synthesize style = _style;
@synthesize animationImage = _animationImage;
@synthesize textColor = _textColor;
@synthesize shadowColor = _shadowColor;

- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor shadowColor:(UIColor *)shadowColor
{
    if((self = [super initWithFrame:frame]))
    {
        self.canTriggerRefresh = YES;
        
        self.textColor = textColor;
        self.shadowColor = shadowColor;
        
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		//self.backgroundColor = [UIColor colorWithRed:196.0/255.0 green:200.0/255.0 blue:209.0/255.0 alpha:1.0];
        self.backgroundColor = [UIColor clearColor];
        
//		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		UILabel *label = [[UILabel alloc] init];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.backgroundColor = [UIColor clearColor];
		[self addSubview:label];
		_lastUpdatedLabel=label;
		
//		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
		label = [[UILabel alloc] init];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.backgroundColor = [UIColor clearColor];
		[self addSubview:label];
		_statusLabel=label;
		
		CALayer *layer = [CALayer layer];
//		layer.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//		view.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
        
        //动画图片
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setAnimationImages:[NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"tmall_loading_6.png"],
                                       [UIImage imageNamed:@"tmall_loading_7.png"],
                                       [UIImage imageNamed:@"tmall_loading_8.png"],
                                       [UIImage imageNamed:@"tmall_loading_9.png"],
                                       [UIImage imageNamed:@"tmall_loading_8.png"],
                                       [UIImage imageNamed:@"tmall_loading_7.png"],
                                       [UIImage imageNamed:@"tmall_loading_6.png"],
                                       [UIImage imageNamed:@"tmall_loading_5.png"],
                                       [UIImage imageNamed:@"tmall_loading_4.png"],
                                       [UIImage imageNamed:@"tmall_loading_3.png"],
                                       [UIImage imageNamed:@"tmall_loading_2.png"],
                                       [UIImage imageNamed:@"tmall_loading_1.png"],
                                       [UIImage imageNamed:@"tmall_loading_2.png"],
                                       [UIImage imageNamed:@"tmall_loading_3.png"],
                                       [UIImage imageNamed:@"tmall_loading_4.png"],
                                       nil]];
        [imageView setAnimationDuration:1.0];
        [imageView setImage:[[UIImage imageNamed:@"tmall_loading_5.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:2]];
        [self addSubview:imageView];
        _animationImage = imageView;
		
		
		[self setState:EGOOPullRefreshNormal];
		
        // 计算topDistance
        _topDistance = fabs(CGRectGetMaxY(frame));
//        _topDistance = 0;
        
        self.style = EGOPullRefreshDefault;
    }
	
    return self;
	
}

- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor
{
    return [self initWithFrame:frame arrowImageName:arrow textColor:textColor shadowColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];	
}

- (id)initWithFrame:(CGRect)frame  {
  return [self initWithFrame:frame arrowImageName:@"EGORefreshTable.bundle/blueArrow.png" textColor:TEXT_COLOR];
}

- (void)setStyle:(EGOPullRefreshStyle)style
{
    _style = style;
    
    if(_style == EGOPullRefreshDefault)
    {
        _lastUpdatedLabel.frame = CGRectMake(0.0f, self.frame.size.height - 30.0f, self.frame.size.width, 20.0f);
		_lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
		_lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
		_lastUpdatedLabel.textColor = self.textColor;
		_lastUpdatedLabel.shadowColor = self.shadowColor;//[UIColor colorWithWhite:0.9f alpha:1.0f];
		_lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        _statusLabel.frame = CGRectMake(0.0f, self.frame.size.height - 48.0f, self.frame.size.width, 20.0f);
		_statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
		_statusLabel.textColor = self.textColor;
		_statusLabel.shadowColor = self.shadowColor;//[UIColor colorWithWhite:0.9f alpha:1.0f];
		_statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		_statusLabel.textAlignment = UITextAlignmentCenter;
        
        _arrowImage.frame = CGRectMake(25.0f, self.frame.size.height - 65.0f, 30.0f, 55.0f);
        _arrowImage.hidden = NO;
        
        _activityView.frame = CGRectMake(25.0f, self.frame.size.height - 38.0f, 20.0f, 20.0f);
        _activityView.hidden = YES;
        
        _animationImage.hidden = YES;
        
    }
    else if(_style == EGOPullRefreshImage)
    {
        _lastUpdatedLabel.frame = CGRectMake(20.0f, self.frame.size.height - 24.0f, self.frame.size.width - _animationImage.image.size.width - 30, 20.0f);
		_lastUpdatedLabel.textAlignment = UITextAlignmentLeft;
        _lastUpdatedLabel.font = [UIFont systemFontOfSize:10];
        _lastUpdatedLabel.textColor = [UIColor colorWithRed:128/255.0f green:128/255.0f blue:128/255.0f alpha:1.0];
        _lastUpdatedLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _lastUpdatedLabel.shadowColor = [UIColor whiteColor];
        
        _statusLabel.frame = CGRectMake(20.0f, self.frame.size.height - 42.0f, self.frame.size.width -_animationImage.image.size.width - 30, 20.0f);
		_statusLabel.textAlignment = UITextAlignmentLeft;
        _statusLabel.font = [UIFont systemFontOfSize:12];
        _statusLabel.textColor = [UIColor colorWithRed:128/255.0f green:128/255.0f blue:128/255.0f alpha:1.0];
        _statusLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _statusLabel.shadowColor = [UIColor whiteColor];
        
        _arrowImage.hidden = YES;
        
        _activityView.hidden = YES;
        
        _animationImage.frame = CGRectMake(self.frame.size.width - _animationImage.image.size.width - 10, self.frame.size.height - _animationImage.image.size.height - 6, _animationImage.image.size.width, _animationImage.image.size.height);
        _animationImage.hidden = NO;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if(self.superview != newSuperview)
    {
        if(self.superview && [self.superview isKindOfClass:[UIScrollView class]])
        {
            [self.superview removeObserver:self forKeyPath:@"contentOffset"];
        }
        
        if(newSuperview && [newSuperview isKindOfClass:[UIScrollView class]])
        {
            [newSuperview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"])
    {
        if(_state == EGOOPullRefreshPulling || _state == EGOOPullRefreshNormal)
        {
            if ([self.animationImage isAnimating]) {
                [self.animationImage stopAnimating];
            }
            CGRect rect = self.animationImage.frame;
            rect.origin.y = [self getBottomY:(UIScrollView *)self.superview];
            rect.size.height = - [self getBottomY:(UIScrollView *)self.superview] + self.frame.size.height - 6.0f;
            self.animationImage.frame = rect;
        }
        else
        {
            if(![self.animationImage isAnimating])
                [self.animationImage startAnimating];
            
            self.animationImage.frame = CGRectMake(self.frame.size.width - _animationImage.image.size.width - 10, self.frame.size.height - _animationImage.image.size.height - 6, _animationImage.image.size.width, _animationImage.image.size.height);
            
            if(((UIScrollView *)self.superview).contentOffset.y < -65 - _topDistance)
            {
                if ([self.animationImage isAnimating]) {
                    [self.animationImage stopAnimating];
                }
                CGRect rect = self.animationImage.frame;
                rect.origin.y = [self getBottomY:(UIScrollView *)self.superview];
                rect.size.height = - [self getBottomY:(UIScrollView *)self.superview] + self.frame.size.height - 6.0f;
                self.animationImage.frame = rect;
            }
            else
            {
                if(![self.animationImage isAnimating])
                    [self.animationImage startAnimating];
                
                self.animationImage.frame = CGRectMake(self.frame.size.width - _animationImage.image.size.width - 10, self.frame.size.height - _animationImage.image.size.height - 6, _animationImage.image.size.width, _animationImage.image.size.height);
            }
        }
    }
        
}

#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		//[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		//[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"HH:mm"];
        
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"上次加载: %@",
                                  [dateFormatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		
		_lastUpdatedLabel.text = nil;
		
	}

}

- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			
			_statusLabel.text = _statusPullingText? _statusPullingText: NSLocalizedString(@"Release to refresh status", @"Release to refresh...");
            if(self.style == EGOPullRefreshDefault)
            {
                [CATransaction begin];
                [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
                _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
                [CATransaction commit];
            }
			
			break;
		case EGOOPullRefreshNormal:
            
			_statusLabel.text = _statusNormalText? _statusNormalText: NSLocalizedString(@"Pull down to refresh status", @"Pull down to refresh...");
            if(self.style == EGOPullRefreshDefault)
            {
                if (_state == EGOOPullRefreshPulling) {
                    [CATransaction begin];
                    [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
                    _arrowImage.transform = CATransform3DIdentity;
                    [CATransaction commit];
                }
                [_activityView stopAnimating];
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                _arrowImage.hidden = NO;
                _arrowImage.transform = CATransform3DIdentity;
                [CATransaction commit];
            }
            else if(self.style == EGOPullRefreshImage)
            {
                [_animationImage stopAnimating];
            }
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
			
			_statusLabel.text = _statusLoadingText? _statusLoadingText: NSLocalizedString(@"Loading Status", @"Loading...");
            if(self.style == EGOPullRefreshDefault)
            {
                [_activityView startAnimating];
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                _arrowImage.hidden = YES;
                [CATransaction commit];
            }
            else if(self.style == EGOPullRefreshImage)
            {
                [_animationImage startAnimating];
            }
			
			break;
		default:
			break;
	}
	
	_state = aState;
}


- (BOOL)isBottomView
{
    if (self.frame.origin.y > 0) {
        return YES;
    }
    
    return NO;
}

- (CGFloat)getBottomY:(UIScrollView *)scrollView
{
    return ((self.frame.origin.y-scrollView.bounds.size.height) - scrollView.contentOffset.y);
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {	
	
	if (_state == EGOOPullRefreshLoading) {
		
        if (![self isBottomView])
        {
            // 下拉
            CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
            offset = MIN(offset, 60+_topDistance);
            scrollView.contentInset = UIEdgeInsetsMake(offset, scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right);
        }
        else
        {
            // 上拉
            CGFloat bottomY = [self getBottomY:scrollView];
            CGFloat offset = MAX(bottomY * -1, 0);
            offset = MIN(offset, 60);
            scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, offset, scrollView.contentInset.right);
        }
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		
        if (![self isBottomView])
        {
            // 下拉
            if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f-_topDistance && scrollView.contentOffset.y < _topDistance && !_loading) {
                [self setState:EGOOPullRefreshNormal];
            } else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f-_topDistance && !_loading) {
                [self setState:EGOOPullRefreshPulling];
            }
            
            if (scrollView.contentInset.top != _topDistance) {
                scrollView.contentInset = UIEdgeInsetsMake(0.0f+_topDistance, scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right);
            }
        }
        else
        {
            // 上拉
            CGFloat bottomY = [self getBottomY:scrollView];

            if (_state == EGOOPullRefreshPulling && bottomY > -65.0f && bottomY < 0.0f && !_loading) {
                [self setState:EGOOPullRefreshNormal];
            } else if (_state == EGOOPullRefreshNormal && bottomY < -65.0f && !_loading) {
                [self setState:EGOOPullRefreshPulling];
            }
            
            if (scrollView.contentInset.bottom != 0) {
                scrollView.contentInset = UIEdgeInsetsZero;
            }
        }
		
	}
	
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    
    if (!self.canTriggerRefresh) {
        return;
    }
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
    if (![self isBottomView])
    {
        // 下拉
        if (scrollView.contentOffset.y <= -65.0f-_topDistance && !_loading) {
            
            if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
                [_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
            }
            
            [self setState:EGOOPullRefreshLoading];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            scrollView.contentInset = UIEdgeInsetsMake(60.0f+_topDistance, scrollView.contentInset.left, scrollView.contentInset.bottom, scrollView.contentInset.right);
            [UIView commitAnimations];
            
        }
    }
    else
    {
        // 上拉
        CGFloat bottomY = [self getBottomY:scrollView];
        
        if (bottomY <= - 65.0f && !_loading) {
            
            if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
                [_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
            }
            
            [self setState:EGOOPullRefreshLoading];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, 60.0f, scrollView.contentInset.right);
            [UIView commitAnimations];
            
        }
    }
    
	
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f+_topDistance, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];

}

- (void)setStatusText:(NSString *)text forStatus:(EGOPullRefreshState)status
{
    switch (status) {
        case EGOOPullRefreshNormal:
            _statusNormalText = [text copy];
            break;
            
        case EGOOPullRefreshPulling:
            _statusPullingText = [text copy];
            break;
            
        case EGOOPullRefreshLoading:
            _statusLoadingText = [text copy];
            break;
    }
    
    [self setState:_state];
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    
    _statusNormalText = nil;
    _statusPullingText = nil;
    _statusLoadingText = nil;
    
    _animationImage = nil;
    
    _textColor = nil;
    _shadowColor = nil;
}


@end
