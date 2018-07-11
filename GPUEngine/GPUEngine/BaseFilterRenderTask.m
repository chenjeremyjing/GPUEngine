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

@end

@implementation BaseFilterRenderTask

#pragma mark -- Common Methods
- (void)addTarget:(id<GPUImageInput>)target {
    [self.filterLinerStyleHelper.sufixFilter addTarget:target];
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
    [baseTexture addTarget:self.baseTransFilter];
    
    //底图滤镜风格
    [self.baseTransFilter addTarget:self.filterLinerStyleHelper.prefixFilter];
    
    //底图颜色抠图轮廓滤镜
    [baseTexture addTarget:self.colorMaskfilter];
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

@end
