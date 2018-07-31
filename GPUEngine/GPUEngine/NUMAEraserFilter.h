//
//  NUMAEraserFilter.h
//  GPUEngine
//
//  Created by BeautyHZ on 2018/7/26.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface NUMAEraserFilter : GPUImageTwoInputFilter
{
    GLint isEraser_Uniform;
    GLint eraserOpacity_Uniform;
    GLint strokeSize_Uniform;
    GLint position_Uniform;
    
}

@property(assign, nonatomic) BOOL isEraser;
@property(assign, nonatomic) CGFloat eraserOpacity;
@property(assign, nonatomic) CGFloat strokeSize;
@property(assign, nonatomic) CGPoint position;

@end
