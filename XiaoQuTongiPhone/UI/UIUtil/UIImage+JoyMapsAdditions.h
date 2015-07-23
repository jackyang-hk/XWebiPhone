//
//  UIImage+JoyMapsAdditions.h
//  JoyMaps
//
//  Created by laijiandong on 13-4-3.
//  Copyright (c) 2013年 taobao inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JMImageScaleType) {
	JMImageScaleTypeFit = 0x01,  // MIN(w, h) as minmual value, and another value greater than this value.
	JMImageScaleTypeFill         // MAX(w, h) as maxumal value, and another value less than this value.
};


@interface UIImage (JM_Additions)

+ (UIImage *)ipMaskedImageNamed:(NSString *)name color:(UIColor *)color;

+ (UIImage *)imageNamed:(NSString *)imageName leftCapAnchor:(float)left topCapAnchor:(float)top;

// Create image with specified color and size, return nil when color is nil or size is CGSizeZero
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

// create image with specified size and custom drawing block
+ (UIImage *)imageWithSize:(CGSize)size drawingBlock:(void (^)(CGContextRef, CGRect))drawingBlock;

- (UIImage *)scaleToSize:(CGSize)newSize type:(JMImageScaleType)type;

@end
