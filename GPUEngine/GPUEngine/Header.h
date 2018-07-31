//
//  Header.h
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/3.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifndef Header_h
#define Header_h

#import <Photos/Photos.h>
#import "NUMAMultiplyBlendFilter.h"
#import "GPUImageMovie+RenderBlock.h"

#define exportScaleValue(number) ceilf( number * 1.0/ 16) * 16
#define panelSize CGSizeMake(exportScaleValue([UIScreen mainScreen].bounds.size.width), exportScaleValue([UIScreen mainScreen].bounds.size.width))

typedef void(^processingBlock)(CGFloat progress);
typedef  enum GPUVideoSpeedType{
    GPUVideoSpeedNormalType,
    GPUVideo4SpeedAccelerateType,
    GPUVideo2SpeedAccelerateType,
    GPUVideo4SpeedDecelerateType,
    GPUVideo2SpeedDecelerateType,
}GPUVideoSpeedType ;

struct render_color {
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat offset;
};
typedef struct render_color render_color;

typedef NS_ENUM(NSInteger, currentTarget)
{
    currentTargetBase,
    currentTargetFill,
    currentTargetText,
    currentTargetEraser,

};

#import "GPURenderEngine.h"

#endif /* Header_h */
