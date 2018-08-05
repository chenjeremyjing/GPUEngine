//
//  NUMAEraserProcess.h
//  GPUEngine
//
//  Created by BeautyHZ on 2018/7/31.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUMAEraserProcess : NSObject


/**
 重制橡皮擦

 @param eraserData 橡皮擦地址
 @param size 橡皮擦大小
 */
+ (unsigned char *)resetEraseDataWithData:(unsigned char *)eraserData size:(CGSize)size;


/**
 更新橡皮擦

 @param eraserData 橡皮擦地址
 @param eraserSize 橡皮擦大小
 @param strokeImg 橡皮擦笔触图
 @param eraseTouchSize 橡皮擦笔触大小
 @param isEraseType 擦除／修补
 @param eraseTouchOpacity 橡皮擦不透明度
 @param lastPoint 上一个擦除点
 @param currentPoint 当前擦除点
 @param touchSpeed 擦出速度
 @param rotation 旋转
 @return 橡皮擦
 */
+ (unsigned char *)updateEraseDataWithData:(unsigned char *)eraserData
                          eraserSize:(CGSize)eraserSize
                           strokeImg:(UIImage *)strokeImg
                      eraseTouchSize:(CGFloat)eraseTouchSize
                           eraseType:(BOOL)isEraseType
                   eraseTouchOpacity:(CGFloat)eraseTouchOpacity
                           lastPoint:(CGPoint)lastPoint
                        currentPoint:(CGPoint)currentPoint
                          touchSpeed:(NSTimeInterval)touchSpeed
                            rotation:(CGFloat)rotation;
@end
