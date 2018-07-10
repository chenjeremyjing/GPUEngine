//
//  FillFilterRenderTask.m
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "FillFilterRenderTask.h"

@interface FillFilterRenderTask()

//填充涂层变形滤镜
@property (nonatomic, strong) GPUImageTransformFilter *fillTransFilter;

@property (nonatomic, strong) FilterLineStyleHelper *filterLinerStyleHelper;

@end

@implementation FillFilterRenderTask

#pragma mark -- Common Methods
- (void)addTarget:(id<GPUImageInput>)target {
    [self.filterLinerStyleHelper.sufixFilter addTarget:target];
}

#pragma mark -- Setter && Getter
- (void)setFillTexture:(GPUImageOutput *)fillTexture {
    [_fillTexture removeAllTargets];
    _fillTexture = fillTexture;
    [_fillTexture addTarget:self.fillTransFilter];
    [self.fillTransFilter addTarget:self.filterLinerStyleHelper.prefixFilter];
}

- (void)setFilterStyle:(FilterLineStyleType)filterStyle {
    _filterStyle = filterStyle;
    self.filterLinerStyleHelper.filterStyle = filterStyle;
}

- (void)setFillTransform:(CATransform3D)fillTransform {
    _fillTransform = fillTransform;
    self.fillTransFilter.transform3D = fillTransform;
}

- (void)setCompensationColor:(UIColor *)compensationColor {
    _compensationColor = compensationColor;
    self.filterLinerStyleHelper.compensationColor = compensationColor;
}

- (void)setCompensationAlpha:(CGFloat)compensationAlpha {
    _compensationAlpha  = compensationAlpha;
    self.filterLinerStyleHelper.compensationAlpha = compensationAlpha;
}

- (GPUImageTransformFilter *)fillTransFilter {
    if (!_fillTransFilter) {
        _fillTransFilter = [[GPUImageTransformFilter alloc] init];
    }
    return _fillTransFilter;
}

- (FilterLineStyleHelper *)filterLinerStyleHelper {
    if (!_filterLinerStyleHelper) {
        _filterLinerStyleHelper = [[FilterLineStyleHelper alloc] init];
        
    }
    return _filterLinerStyleHelper;
}

@end
