//
//  FilterLineStyleHelper.m
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "FilterLineStyleHelper.h"
#import "ColorCompensationFilter.h"

@interface FilterLineStyleHelper()

//滤镜风格 纯色补偿滤镜
@property (nonatomic, strong) ColorCompensationFilter *colorCompensationFilter;

@end

@implementation FilterLineStyleHelper

#pragma mark -- Init methods
+ (instancetype)filterLineWithStyle:(FilterLineStyleType)filterStyle
{
    FilterLineStyleHelper *filterStyleHelper = [[FilterLineStyleHelper alloc] init];
    filterStyleHelper.filterStyle = FilterLineCityStyleType;
    filterStyleHelper.colorCompensationFilter = [[ColorCompensationFilter alloc] init];
    return filterStyleHelper;
}

#pragma mark -- Setter && Getter
- (void)setFilterStyle:(FilterLineStyleType)filterStyle {
    _filterStyle = filterStyle;
    switch (filterStyle) {
        case FilterLineCartoonStyleType:
        {
            GPUImageSaturationFilter *saturationfilter = [[GPUImageSaturationFilter alloc] init];
            GPUImageContrastFilter *contrastfilter = [[GPUImageContrastFilter alloc] init];
//            GPUImageFilterPipeline *line = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:@[saturationfilter, contrastfilter] input:nil output:nil];
            self.firstAdjustFilter = saturationfilter;
            self.secondAdjustFilter = contrastfilter;
            self.prefixFilter = saturationfilter;
            self.secondAdjustFilter = contrastfilter;
        }
            break;
        case FilterLineCityStyleType:
        {
            GPUImageSaturationFilter *saturationfilter = [[GPUImageSaturationFilter alloc] init];
            GPUImageContrastFilter *contrastfilter = [[GPUImageContrastFilter alloc] init];
            //            GPUImageFilterPipeline *line = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:@[saturationfilter, contrastfilter] input:nil output:nil];
            self.firstAdjustFilter = saturationfilter;
            self.secondAdjustFilter = contrastfilter;
            self.prefixFilter = saturationfilter;
            self.secondAdjustFilter = contrastfilter;
        }
            break;
            
        default:
            break;
    }
}

- (void)setCompensationColor:(UIColor *)compensationColor {
    _compensationColor = compensationColor;
}

- (void)setCompensationAlpha:(CGFloat)compensationAlpha {
    _compensationAlpha = compensationAlpha;
}

@end
