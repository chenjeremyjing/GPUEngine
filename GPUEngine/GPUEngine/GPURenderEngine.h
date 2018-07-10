//
//  GPURenderEngine.h
//  GPUEngine
//
//  Created by Jeremy Liu on 18/6/28.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class filterLineGroup;
@class FilterTest;
@class Gfilter;

typedef void(^filterAdjustBlock)(FilterTest *filter);
typedef void(^processingBlock)(CGFloat progress);
typedef  enum GPUVideoSpeedType{
    GPUVideoSpeedNormalType,
    GPUVideo4SpeedAccelerateType,
    GPUVideo2SpeedAccelerateType,
    GPUVideo4SpeedDecelerateType,
    GPUVideo2SpeedDecelerateType,
}GPUVideoSpeedType ;

@interface GPURenderEngine : NSObject



/**
 切换底图和填充涂层的混合效果

 @param blendFilter 混合效果滤镜
 */
- (void)updateBaseAndFillBlendFilter:(Gfilter *)blendFilter;

#pragma mark -- 底图相关处理接口方法
/**
 底图涂层切换资源

 @param baseImage 底图图片
 */
- (void)updateBaseResourceWithImage:(UIImage *)baseImage;


/**
 切换底图滤镜风格

 @param filterLine 风格滤镜链
 @param oneFilter 风格滤镜链可调滤镜1
 @param anotherFilter 风格滤镜链可调滤镜2
 */
- (void)updateBaseFilterStyleWithFilterLine:(filterLineGroup *)filterLine adjustOneFilter:(filterAdjustBlock)oneFilter anotherFilter:(filterAdjustBlock)anotherFilter;

#pragma mark -- 填充涂层相关接口方法
/**
 填充层切换资源 - 图片

 @param fillImage 切换图片
 */
- (void)updateFillResourceWithImage:(UIImage *)fillImage;


/**
 填充层切换资源 - 视频资源

 @param videoAsset 视频资源
 */
- (void)updateFillResourceWithVideoAsset:(AVAsset *)videoAsset;


/**
 切换填充层滤镜风格

 @param filterLine 风格滤镜链
 @param oneFilter 风格滤镜链可调滤镜1
 @param anotherFilter 风格滤镜链可调滤镜2
 */
- (void)updateFillFilterStyleWithFilterLine:(filterLineGroup *)filterLine adjustOneFilter:(filterAdjustBlock)oneFilter anotherFilter:(filterAdjustBlock)anotherFilter;


/**
 填充层Transform调整

 @param transform transform
 */
- (void)updateFillWithTransform:(CATransform3D)transform;


/**
 填充层 纯色补偿 切换补偿颜色

 @param compensationColor 颜色
 */
- (void)updateFillCompensationColor:(UIColor *)compensationColor;


/**
 填充层 纯色补偿不透明度调整

 @param alpha 不透明度
 */
- (void)updateFillCompensationColorAlpha:(CGFloat)alpha;


#pragma mark -- 填充涂层遮罩相关接口方法

/**
 填充层遮罩 -- 文字遮罩

 @param textImage 文字转成图片
 */
- (void)updateTextMaskWithTextImage:(UIImage *)textImage;


///**
// 填充层遮罩 -- 文字遮罩
//
// @param textLayer 文字转成的layer
// */
//- (void)updateTextMaskWithTextLayer:(CALayer *)textLayer;


/**
 填充层遮罩 -- 文字遮罩的Transform调整

 @param transform 文字遮罩的Transform
 */
- (void)updateTextMaskWithTransform:(CATransform3D)transform;


/**
 填充层遮罩 -- 橡皮擦遮罩

 @param eraserRawData 橡皮擦层纹理Data
 */
- (void)updateEraserMaskWithEraserRawData:(char *)eraserRawData;

/**
 填充层遮罩 -- 颜色镂空遮罩

 @param color 颜色（针对底图）
 @param minToleranceColor 颜色选取范围的偏差最小色
 @param maxToleranceColor 颜色选取范围的偏差最大色
 */
- (void)updateColorMaskWithColor:(UIColor *)color andMinToleranceColor:(UIColor *)minToleranceColor maxToleranceColor:(UIColor *)maxToleranceColor;


/**
 填充涂层及遮罩是否隐藏

 @param isHidden 是否隐藏
 */
- (void)setMaskAndFillHidden:(BOOL)isHidden;


/**
 选取视频资源特定片段调整速度

 @param speed 速度 -4（4倍慢速）  -2（2倍慢速）  0（正常速度）  2（2倍快速） 4（2倍快速）
 @param startTime 视频资源片段的起始时间
 @param endTime 视频资源片段的结束时间
 */
- (void)setFillVideoSpeed:(GPUVideoSpeedType)speed startTime:(CMTime)startTime endTime:(CMTime)endTime;


/**
 导出处理过的视频资源

 @param cachePath 导出路径
 @param progressBlock 导出进度及状态
 */
- (void)exportWithCachePath:(NSString *)cachePath andProcessingBlock:(processingBlock)progressBlock;


@end
