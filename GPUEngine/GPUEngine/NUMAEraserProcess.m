//
//  NUMAEraserProcess.m
//  GPUEngine
//
//  Created by BeautyHZ on 2018/7/31.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "NUMAEraserProcess.h"

@implementation NUMAEraserProcess
+ (void)resetEraseDataWithData:(unsigned char *)eraserData size:(CGSize)size {
    
    if (eraserData != NULL) {
        free(eraserData);
        eraserData = NULL;
    }
    
    const size_t bitsPerComponent = 8;
    const size_t bytesPerRow = size.width * 4; //1byte per pixel
    eraserData = calloc(sizeof(unsigned char), bytesPerRow * size.height);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef context =
    CGBitmapContextCreate(eraserData, size.width, size.height,
                          bitsPerComponent, bytesPerRow,
                          colorSpaceRef,
                          kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpaceRef);
    if(NULL == context) {
        NSLog(@"resetEraseData: Could not create the context");
        CGContextRelease(context);
        return;
    }
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:1 green:0 blue:0 alpha:0] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    CGContextRelease(context);
}

+ (UIImage *)updateEraseDataWithData:(unsigned char *)eraserData
                          eraserSize:(CGSize)eraserSize
                           strokeImg:(UIImage *)strokeImg
                      eraseTouchSize:(CGFloat)eraseTouchSize
                           eraseType:(BOOL)isEraseType
                   eraseTouchOpacity:(CGFloat)eraseTouchOpacity
                           lastPoint:(CGPoint)lastPoint
                        currentPoint:(CGPoint)currentPoint
                          touchSpeed:(NSTimeInterval)touchSpeed
                            rotation:(CGFloat)rotation {
    
    
    @autoreleasepool {
        //未生成笔触图片则不进行处理
        if (!strokeImg) {
            return nil;
        }
        
        const size_t bitsPerComponent = 8;
        const size_t bytesPerRow = eraserSize.width * 4; //1byte per pixel
        if(NULL == eraserData) {
            [self resetEraseDataWithData:eraserData size:eraserSize];
        }
        
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGContextRef context =
        CGBitmapContextCreate(eraserData, eraserSize.width, eraserSize.height,
                              bitsPerComponent, bytesPerRow,
                              colorSpaceRef,
                              kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGColorSpaceRelease(colorSpaceRef);
        if(NULL == context) {
            NSLog(@"updateEraseData: Could not create the context");
            CGContextRelease(context);
            return nil;
        }
        
        
        CGContextSetShouldAntialias(context, true);
        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetBlendMode(context,isEraseType ? kCGBlendModeNormal : kCGBlendModeDestinationOut);
        
        CGContextTranslateCTM(context, 0, eraserSize.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        if (((rotation / M_PI_2) !=  (int)(rotation / M_PI_2))) {
            CGContextRotateCTM(context, -rotation);
            lastPoint = [self point:lastPoint rotate:rotation];
            currentPoint = [self point:currentPoint rotate:rotation];
        }
        
        //当传入参数都有具体坐标时，进行绘图
        if (!CGPointEqualToPoint(lastPoint, CGPointZero) && !CGPointEqualToPoint(currentPoint, CGPointZero)) {
            CGPoint vector = CGPointMake(currentPoint.x - lastPoint.x, currentPoint.y - lastPoint.y);
            CGFloat distance = hypotf(vector.x, vector.y);
            vector.x /= distance;
            vector.y /= distance;
            
            //笔触透明度
            CGFloat opacity = 0.74f + (1 - 0.74f)*eraseTouchOpacity;
            opacity = tan(opacity * 1.54) / tan(1.54) * opacity / 2;
            
            NSLog(@"%@", NSStringFromCGPoint(lastPoint));
            
            if (distance == 0) {
                CGContextSetAlpha(context, eraseTouchOpacity);
                CGContextDrawImage(context,
                                   CGRectMake(lastPoint.x-eraseTouchSize/2,lastPoint.y-eraseTouchSize/2,eraseTouchSize,eraseTouchSize),
                                   [strokeImg CGImage]);
            }
            else {
                
                //                ACLog(@"distance:%lf,.....%lf",distance,distance/touchSpeed/eraseTouchSize/eraseTouchOpacity);
                CGContextSetAlpha(context, opacity/2);
                for (CGFloat i = 0; i <= distance; i += 3.0f) {
                    CGPoint p = CGPointMake(lastPoint.x + i * vector.x, lastPoint.y + i * vector.y);
                    CGContextDrawImage(context, CGRectMake(p.x-eraseTouchSize/2,p.y-eraseTouchSize/2,eraseTouchSize,eraseTouchSize), [strokeImg CGImage]);
                }
            }
        }
        CGImageRef newImage = CGBitmapContextCreateImage(context);
        UIImage * eraseImage = [UIImage imageWithCGImage:newImage];
        CGContextRelease(context);
        CGImageRelease(newImage);
        return eraseImage;
    }
}

+ (CGPoint)point:(CGPoint)originPoint rotate:(CGFloat)rotate {
    
    CGFloat rotatePointX = originPoint.x * cos(rotate) - originPoint.y * sin(rotate);
    CGFloat rotatePointY = originPoint.x * sin(rotate) + originPoint.y * cos(rotate);
    
    return CGPointMake(rotatePointX, rotatePointY);
}


@end
