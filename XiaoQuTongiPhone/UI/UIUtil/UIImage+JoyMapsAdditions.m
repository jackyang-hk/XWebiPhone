//
//  UIImage+JoyMapsAdditions.m
//  JoyMaps
//
//  Created by laijiandong on 13-4-3.
//  Copyright (c) 2013年 taobao inc. All rights reserved.
//

#import "UIImage+JoyMapsAdditions.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "UIImage+JoyMapsAdditions requires ARC support."
#endif

@implementation UIImage (JM_Additions)

+ (UIImage *)ipMaskedImageNamed:(NSString *)name color:(UIColor *)color
{
    UIImage *image = [UIImage imageNamed:name];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+ (UIImage *)imageNamed:(NSString *)imageName leftCapAnchor:(float)left topCapAnchor:(float)top {
    UIImage *image = [UIImage imageNamed:imageName];
    if (image != nil) {
        CGSize size = image.size;
        
        static NSInteger mask = 0x00;
        if (mask == 0x00) {
            mask |= 0x0F;
            
            if ([image respondsToSelector:@selector(resizableImageWithCapInsets:)]){
                mask |= 0xF0;
            }
        }
        
        if ((0xF0 & mask) != 0x00) {
            CGFloat topEdge = floorf(size.height * top);
            CGFloat leftEdge = floorf(size.width * left);
            
            CGFloat bottomEdge = size.height - topEdge;
            CGFloat rightEdge = size.width - leftEdge;
            
            UIEdgeInsets capInsets = UIEdgeInsetsMake(topEdge, leftEdge, bottomEdge, rightEdge);
            image = [image resizableImageWithCapInsets:capInsets];
            
        } else {
            image = [image stretchableImageWithLeftCapWidth:(size.width * left)
                                               topCapHeight:(size.height * top)];
        }
    }
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (color == nil || CGSizeEqualToSize(size, CGSizeZero)) return nil;
    
    UIImage *target = [UIImage imageWithSize:size
                                drawingBlock:^(CGContextRef context, CGRect rect) {
                                    CGContextSetFillColorWithColor(context, [color CGColor]);
                                    CGContextFillRect(context, rect);
                                }];
    
    return target;
}

+ (UIImage *)imageWithSize:(CGSize)size drawingBlock:(void (^)(CGContextRef, CGRect))drawingBlock {
    if (CGSizeEqualToSize(size, CGSizeZero)) return nil;
    
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    if (drawingBlock != nil) {
        drawingBlock(context, rect);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)cropToCircleWithSource:(UIImage *)source radius:(CGFloat)radius {
    if (source == nil || radius < 1.0) return nil;
    
    CGSize size = CGSizeMake(2 * radius, 2 * radius);
    void (^drawingBlock)(CGContextRef, CGRect) = ^(CGContextRef context, CGRect rect) {
        CGContextClearRect(context, rect);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
        CGContextAddPath(context, path.CGPath);
        CGContextClip(context);
        
        // save context
        CGContextSaveGState(context);
        
        CGSize stageSize = rect.size;
        CGSize sourceSize = source.size;
        
        CGFloat factor = 0.0;
        CGFloat width, height;
        
        if (sourceSize.width < sourceSize.height) {
            factor = stageSize.width / sourceSize.width;
            width = stageSize.width;
            height = factor * sourceSize.height;
            
        } else {
            factor = stageSize.height / sourceSize.height;
            height = stageSize.height;
            width = factor * sourceSize.width;
        }
        
        CGRect drawingRect = CGRectMake((stageSize.width - width) * 0.5, (stageSize.height - height) * 0.5, width, height);
        [source drawInRect:drawingRect];
    };
    
    UIImage *target = [UIImage imageWithSize:size drawingBlock:drawingBlock];
    
    return target;
}

- (UIImage *)scaleToSize:(CGSize)newSize type:(JMImageScaleType)type {
	CGFloat width, height;
	CGSize imageSize = self.size;
	CGFloat factor = 0.0;
	
	CGSize finalSize = CGSizeZero;
	if (imageSize.width > imageSize.height + 0.01) {
		finalSize = CGSizeMake(MAX(newSize.width, newSize.height), MIN(newSize.width, newSize.height));
        
	} else {
		finalSize = CGSizeMake(MIN(newSize.width, newSize.height), MAX(newSize.width, newSize.height));
	}
	
	if (JMImageScaleTypeFit == type) {
		if (imageSize.width + 0.01 < imageSize.height) {
			width = MIN(imageSize.width, finalSize.width);
			height = width / imageSize.width * imageSize.height;
			
		} else {
			height = MIN(imageSize.height, finalSize.height);
			width = height / imageSize.height * imageSize.width;
		}
		
	} else{
		if (imageSize.width > finalSize.width + 0.01
            || imageSize.height > finalSize.height + 0.01){
			
			if (imageSize.width > imageSize.height) {
				factor = finalSize.width / imageSize.width;
				width = finalSize.width;
				height = factor * imageSize.height;
				
			}else {
				factor = finalSize.height / imageSize.height;
				height = finalSize.height;
				width = factor * imageSize.width;
			}
			
		} else {
			width = imageSize.width;
			height = imageSize.height;
		}
	}
	
	finalSize = CGSizeMake(floorf(width), floorf(height));
	
	UIGraphicsBeginImageContext(finalSize);
	
	[self drawInRect:CGRectMake(0.0, 0.0, finalSize.width, finalSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return newImage;
}

@end
