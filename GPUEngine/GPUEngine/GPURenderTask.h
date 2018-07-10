//
//  GPURenterTask.h
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

struct render_color {
    CGFloat r;
    CGFloat g;
    CGFloat b;
};

struct colorWithTolerance {
    struct render_color color;
    struct render_color color_Min;
    struct render_color color_Max;
    
};

@interface GPURenderTask : NSObject

- (void)addTarget:(id<GPUImageInput>)target;

- (void)removeAllTarget;

- (void)processAll;


@end
