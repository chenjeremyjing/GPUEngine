//
//  BaseFilterRenderTask.m
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "BaseFilterRenderTask.h"

@interface BaseFilterRenderTask()

//底图移动滤镜
@property (nonatomic, strong) GPUImageTransformFilter *baseTransFilter;

//底图风格滤镜组
@property (nonatomic, strong) FilterLineStyleHelper *filterLinerStyleHelper;

@property (nonatomic, copy) RenderBlock renderBlock;

@end

@implementation BaseFilterRenderTask

#pragma mark -- Common Methods
- (void)addTarget:(id<GPUImageInput>)target {
    [self.filterLinerStyleHelper.sufixFilter addTarget:target];
}

- (void)removeTarget:(id<GPUImageInput>)target {
    [self.filterLinerStyleHelper.sufixFilter removeTarget:target];
}

- (void)removeAllTarget {
    [self.filterLinerStyleHelper.sufixFilter removeAllTargets];
}

- (void)updateStyleFilterLineParamValueOne:(CGFloat)valueOne
{
    //    self.filterLinerStyleHelper.firstAdjustFilter.
}

- (void)updateStyleFilterLineParamValueTwo:(CGFloat)valueTwo
{
    //    self.filterLinerStyleHelper.firstAdjustFilter.
}

#pragma mark -- Setter && Getter
- (GPUImageTransformFilter *)baseTransFilter {
    if (!_baseTransFilter) {
        _baseTransFilter = [[GPUImageTransformFilter alloc] init];
    }
    return _baseTransFilter;
}

- (ColorMaskFilter *)colorMaskfilter {
    if (!_colorMaskfilter) {
        _colorMaskfilter = [[ColorMaskFilter alloc] init];
    }
    return _colorMaskfilter;
}

- (FilterLineStyleHelper *)filterLinerStyleHelper {
    if (!_filterLinerStyleHelper) {
        _filterLinerStyleHelper = [FilterLineStyleHelper filterLineWithStyle:FilterLineCartoonStyleType];
    }
    return _filterLinerStyleHelper;
}


- (void)setBaseTexture:(GPUImagePicture *)baseTexture {
    [_baseTexture removeAllTargets];
    _baseTexture = baseTexture;
    
    //底图移动滤镜
    [_baseTexture addTarget:self.baseTransFilter];
    
    self.baseTransFilter.transform3D = CATransform3DIdentity;
    
    //底图滤镜风格
    [self.baseTransFilter addTarget:self.filterLinerStyleHelper.prefixFilter];
    
    //底图颜色抠图轮廓滤镜
    [self.baseTransFilter addTarget:self.colorMaskfilter];
}

- (void)setBaseTransform:(CATransform3D)baseTransform {
    _baseTransform = baseTransform;
    self.baseTransFilter.transform3D = _baseTransform;
}

- (void)setMaskColor:(render_color)maskColor{
    _maskColor = maskColor;
    self.colorMaskfilter.r = maskColor.r;
    self.colorMaskfilter.g = maskColor.g;
    self.colorMaskfilter.b = maskColor.b;
    self.colorMaskfilter.offset = maskColor.offset;
}

- (void)setFilterStyle:(FilterLineStyleType)filterStyle {
    _filterStyle = filterStyle;
    [self.baseTransFilter removeTarget:self.filterLinerStyleHelper.prefixFilter];
    self.filterLinerStyleHelper.filterStyle = filterStyle;
    [self.baseTransFilter addTarget:self.filterLinerStyleHelper.prefixFilter];
}

- (void)processAllWithRenderBlock:(RenderBlock)renderBlock {
    self.renderBlock = renderBlock;
    [self.baseTexture processImage];
    [self.filterLinerStyleHelper startProcessWithRenderBlock:^(BOOL hasAnimationVideo) {
        [self.baseTexture processImage];
        self.hasAnimationVideo = hasAnimationVideo;
        if (self.renderBlock) {
            self.renderBlock(hasAnimationVideo);
        }
    }];
}

- (BOOL)hasAnimationVideo {
    return self.filterLinerStyleHelper.hasAnimationVideo;
}

@end
