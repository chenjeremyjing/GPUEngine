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

#import "NUMAMultiplyBlendFilter.h"

#define panelSize CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)

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
#endif /* Header_h */
