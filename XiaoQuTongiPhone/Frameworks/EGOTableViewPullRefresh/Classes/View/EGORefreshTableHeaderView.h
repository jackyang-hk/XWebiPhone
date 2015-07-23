//
//  EGORefreshTableHeaderView.h
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

/*
 * 增加了可定制的文本提示和上拉刷新。 Add by zhouyi.hyh@taobao.com
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	EGOOPullRefreshPulling = 0,
	EGOOPullRefreshNormal,
	EGOOPullRefreshLoading,	
} EGOPullRefreshState;

typedef enum
{
    EGOPullRefreshDefault = 0,
    EGOPullRefreshImage,
}EGOPullRefreshStyle;

@protocol EGORefreshTableHeaderDelegate;

@interface EGORefreshTableHeaderView : UIView
{
	EGOPullRefreshState _state;

	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	
    NSString * _statusNormalText;
    NSString * _statusPullingText;
    NSString * _statusLoadingText;
    
    CGFloat _topDistance; // 当下拉刷新和scrollview的top之间还有view时，会自动计算这个距离
    
    EGOPullRefreshStyle _style;
    
    UIImageView *_animationImage;
}

@property (assign, nonatomic) BOOL canTriggerRefresh; // 是否可以触发刷新，默认为YES
@property (strong, nonatomic, readonly) UILabel * lastUpdatedLabel;
@property (strong, nonatomic, readonly) UILabel * statusLabel;
@property (strong, nonatomic, readonly) CALayer * arrowImage;
@property (strong, nonatomic, readonly) UIActivityIndicatorView * activityView;
@property (assign, nonatomic) EGOPullRefreshStyle style;
@property (strong, nonatomic) UIImageView *animationImage;

@property(nonatomic, assign) id <EGORefreshTableHeaderDelegate> delegate;

- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor shadowColor:(UIColor *)shadowColor;
- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

- (void)setStatusText:(NSString *)text forStatus:(EGOPullRefreshState)status;

@end

@protocol EGORefreshTableHeaderDelegate <NSObject>

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view;
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view;

@optional
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view;

@end
