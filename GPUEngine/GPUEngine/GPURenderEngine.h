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
#import "FilterLineStyleHelper.h"


@interface GPURenderEngine : NSObject

//最后添加的动态视频纹理 （用于多视频合成）
@property (nonatomic, strong) GPUImageMovie *lastMovie;

//最后添加的动态视频纹理播放器 （用于多视频合成）
@property (nonatomic, strong) AVPlayer *lastVideoPlayer;


//单利初始化方法
+ (instancetype)renderEngine;

/**
 切换底图和填充涂层的混合效果
 
 @param blendFilter 混合效果滤镜
 */
- (void)updateBaseAndFillBlendFilter:(GPUImageTwoInputFilter *)blendFilter;

#pragma mark -- 底图相关处理接口方法
/**
 底图涂层切换资源
 
 @param baseImage 底图图片
 */
- (void)updateBaseResourceWithImage:(UIImage *)baseImage;


/**
 底图移动变形

 @param transform transform
 */
- (void)updateBaseWithTransform:(CATransform3D)transform;


/**
 切换底图滤镜风格
 
 @param filterStyle 滤镜风格枚举
 @param oneFilter 风格滤镜链可调滤镜1
 @param anotherFilter 风格滤镜链可调滤镜2
 */
- (void)updateBaseFilterStyleWithFilterStyle:(FilterLineStyleType)filterStyle;
- (void)updateBaseFilterLineStyleWithOneAdjustValue:(CGFloat)adjustValue;
- (void)updateBaseFilterLineStyleWithSecondAdjustValue:(CGFloat)adjustValue;


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
- (void)updateFillFilterStyleWithFilterStyle:(FilterLineStyleType)filterStyle;
- (void)updateFillFilterLineStyleWithOneAdjustValue:(CGFloat)adjustValue;
- (void)updateFillFilterLineStyleWithSecondAdjustValue:(CGFloat)adjustValue;

- (void)seekToTime:(CMTime)time;


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


/**
 填充层遮罩 -- 文字遮罩

 @param textLayer 文字转成的layer
 */
- (void)updateTextMaskWithTextView:(UIView *)textView;


/**
 填充层遮罩 -- 文字遮罩

 @param text 文字富文本
 */
- (void)updateTextMaskWithText:(NSMutableAttributedString *)text;


/**
 填充层遮罩 -- 文字遮罩的Transform调整
 
 @param transform 文字遮罩的Transform
 */
- (void)updateTextMaskWithTransform:(CATransform3D)transform;


/**
 填充层遮罩 -- 橡皮擦遮罩
 
 @param eraserRawData 橡皮擦层纹理Data
 */
- (void)updateEraserMaskWithEraserRawData:(GLubyte *)eraserRawData;


/**
 填充层遮罩 -- 更新底图颜色抠图遮罩

 */
- (void)updateColorMaskTexture;


/**
 填充层遮罩 -- 颜色镂空遮罩
 
 @param colorAndTolerance 颜色选取数据结构题
 */
- (void)updateColorMaskColorAndTolerance:(render_color)colorAndTolerance;


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
- (void)setFillVideoSpeed:(GPUVideoSpeedType)speed;
- (void)setFillVideoStartTime:(CMTime)startTime;
- (void)setFillVideoEndTime:(CMTime)endTime;


/**
 渲染视图

 @param renderView GPUImageView
 */
- (void)setRenderView:(GPUImageView *)renderView;


/**
 导出处理过的视频资源
 
 @param cachePath 导出路径
 @param progressBlock 导出进度及状态
 */
- (void)exportWithCachePath:(NSString *)cachePath andProcessingBlock:(processingBlock)progressBlock;


@end
