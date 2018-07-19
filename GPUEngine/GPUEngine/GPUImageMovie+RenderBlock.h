//
//  GPUImageMovie+RenderBlock.h
//  GPUEngine
//
//  Created by BeautyHZ on 2018/7/19.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "GPUImageMovie.h"
#import <objc/runtime.h>
typedef void(^renderBlock)();

@interface GPUImageMovie (RenderBlock)
@property (nonatomic, copy) renderBlock renderFrameBlock;

@end
