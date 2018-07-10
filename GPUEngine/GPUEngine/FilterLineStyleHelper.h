//
//  FilterLineStyleHelper.h
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

typedef  enum FilterLineStyleType{
    FilterLineCartoonStyleType,
    FilterLineCityStyleType,

}FilterLineStyleType ;


@interface FilterLineStyleHelper : NSObject

//风格滤镜链可调滤镜 1
@property (nonatomic, strong) GPUImageFilter *firstAdjustFilter;

//风格滤镜链可调滤镜 2
@property (nonatomic, strong) GPUImageFilter *secondAdjustFilter;

//风格滤镜链首滤镜
@property (nonatomic, strong) GPUImageFilter *prefixFilter;

//风格滤镜链尾滤镜
@property (nonatomic, strong) GPUImageFilter *sufixFilter;

//滤镜风格
@property (nonatomic, assign) FilterLineStyleType filterStyle;

//纯色补偿 颜色
@property (nonatomic, strong) UIColor *compensationColor;

//纯色补偿 不透明度
@property (nonatomic, assign) CGFloat compensationAlpha;

+ (instancetype)filterLineWithStyle:(FilterLineStyleType)filterStyle;


@end
