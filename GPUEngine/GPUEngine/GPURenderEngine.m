//
//  GPURenderEngine.m
//  GPUEngine
//
//  Created by Jeremy Liu on 18/6/28.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "GPURenderEngine.h"
#import "BaseFilterRenderTask.h"
#import "FillFilterRenderTask.h"
#import "MaskRenderTask.h"
#import "FillMaskFilter.h"

@interface GPURenderEngine()

@property (nonatomic, strong) BaseFilterRenderTask *baseRenderTask;

@property (nonatomic, strong) FillFilterRenderTask *fillRendereTask;

@property (nonatomic, strong) MaskRenderTask *maskRenderTask;

@property (nonatomic, strong) GPUImageNormalBlendFilter *blendFilter;

@property (nonatomic, strong) FillMaskFilter *maskFilter;


@end

@implementation GPURenderEngine

static GPURenderEngine *engine = nil;

+ (instancetype)renderEngine {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[GPURenderEngine alloc] init];
        engine.baseRenderTask = [[BaseFilterRenderTask alloc] init];
        engine.fillRendereTask = [[FillFilterRenderTask alloc] init];
        engine.maskRenderTask = [[MaskRenderTask alloc] init];
        engine.maskFilter = [[FillMaskFilter alloc] init];
        engine.blendFilter = [[GPUImageNormalBlendFilter alloc] init];
    });
    return engine;
}


//底图
- (void)updateBaseResourceWithImage:(UIImage *)baseImage
{
    self.baseRenderTask.baseTexture = [[GPUImagePicture alloc] initWithImage:baseImage];
}
- (void)updateBaseFilterStyleWithFilterLine:(filterLineGroup *)filterLine adjustOneFilter:(filterAdjustBlock)oneFilter anotherFilter:(filterAdjustBlock)anotherFilter
{
}

//填充
- (void)updateFillResourceWithImage:(UIImage *)fillImage
{
    self.fillRendereTask.fillTexture = [[GPUImagePicture alloc] initWithImage:fillImage];
}

- (void)updateFillResourceWithVideoAsset:(AVAsset *)videoAsset
{
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:videoAsset];
    self.fillRendereTask.fillTexture = [[GPUImageMovie alloc] initWithPlayerItem:playerItem];
}

- (void)updateFillFilterStyleWithFilterLine:(filterLineGroup *)filterLine adjustOneFilter:(filterAdjustBlock)oneFilter anotherFilter:(filterAdjustBlock)anotherFilter
{
    
}

- (void)updateFillWithTransform:(CATransform3D)transform
{
    self.fillRendereTask.fillTransform = transform;
}

- (void)updateFillCompensationColor:(UIColor *)compensationColor
{
    self.fillRendereTask.compensationColor = compensationColor;
}

- (void)updateFillCompensationColorAlpha:(CGFloat)alpha
{
    self.fillRendereTask.compensationAlpha = alpha;
}

//遮罩 文字
- (void)updateTextMaskWithTextImage:(UIImage *)textImage
{
    self.maskRenderTask.textMaskTexture = [[GPUImagePicture alloc] initWithImage:textImage];
}
- (void)updateTextMaskWithTextLayer:(CALayer *)textLayer
{
    //    self.maskRenderTask.textMaskTexture = [
}
- (void)updateTextMaskWithTransform:(CATransform3D)transform
{
    self.maskRenderTask.textMaskTransform = transform;
}

//遮罩橡皮擦
- (void)updateEraserMaskWithEraserRawData:(GLubyte *)eraserRawData
{
    self.maskRenderTask.eraserMaskTexture = [[GPUImageRawDataInput alloc] initWithBytes:eraserRawData size:CGSizeMake(100, 100)];
}

//遮罩颜色
- (void)updateColorMaskColorAndTolerance:(struct colorWithTolerance)colorAndTolerance
{
    self.baseRenderTask.maskColor = colorAndTolerance;
}
- (void)setMaskAndFillHidden:(BOOL)isHidden
{
}

- (void)setFillVideoSpeed:(GPUVideoSpeedType)speed startTime:(CMTime)startTime endTime:(CMTime)endTime{
    
}

- (void)exportWithCachePath:(NSString *)cachePath andProcessingBlock:(processingBlock)progressBlock{
    
}

- (void)processAll
{
    
    
    [self.baseRenderTask processAll];
    [self.fillRendereTask processAll];
    [self.maskRenderTask processAll];
}



@end

