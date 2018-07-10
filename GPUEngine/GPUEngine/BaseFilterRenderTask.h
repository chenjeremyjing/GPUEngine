//
//  BaseFilterRenderTask.h
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "GPURenderTask.h"
#import "FilterLineStyleHelper.h"
#import "ColorMaskFilter.h"

@interface BaseFilterRenderTask : GPURenderTask

//底图纹理
@property (nonatomic, strong) GPUImagePicture *baseTexture;

//底图Transform
@property (nonatomic, assign) CATransform3D baseTransform;

//底图滤镜风格
@property (nonatomic, assign) FilterLineStyleType filterStyle;

//底图滤镜风格纯色补偿颜色
@property (nonatomic, strong) UIColor *compensationColor;

//底图颜色选去楼空轮廓颜色
@property (nonatomic, assign) struct colorWithTolerance maskColor;

//底图颜色轮廓输出
@property (nonatomic, strong) ColorMaskFilter *colorMaskfilter;

@end
