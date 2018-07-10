//
//  FillFilterRenderTask.h
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "GPURenderTask.h"
#import "FilterLineStyleHelper.h"

@interface FillFilterRenderTask : GPURenderTask

//填充层纹理
@property (nonatomic, strong) GPUImageOutput *fillTexture;

//填充层移动Transform
@property (nonatomic, assign) CATransform3D fillTransform;

//填充涂层滤镜风格
@property (nonatomic, assign) FilterLineStyleType filterStyle;

//风格纯色补偿 颜色
@property (nonatomic, strong) UIColor *compensationColor;

//风格纯色补偿 不透明度
@property (nonatomic, assign) CGFloat compensationAlpha;

@end