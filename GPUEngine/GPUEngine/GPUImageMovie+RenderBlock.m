//
//  GPUImageMovie+RenderBlock.m
//  GPUEngine
//
//  Created by BeautyHZ on 2018/7/19.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "GPUImageMovie+RenderBlock.h"
static const char *renderBlockKey = "renderBlockKey";

@implementation GPUImageMovie (RenderBlock)

- (void)setRenderFrameBlock:(renderBlock)renderFrameBlock {
    objc_setAssociatedObject(self, &renderBlockKey, renderFrameBlock, OBJC_ASSOCIATION_COPY);
}

- (renderBlock)renderFrameBlock {
    return objc_getAssociatedObject(self, &renderBlockKey);
}

+ (void)load
{
    Method originMethod = class_getInstanceMethod(self, @selector(processMovieFrame: withSampleTime:));
    Method newMethod = class_getInstanceMethod(self, @selector(numa_processMovieFrame: withSampleTime:));
    method_exchangeImplementations(originMethod, newMethod);
}

- (void)numa_processMovieFrame:(CVPixelBufferRef)movieFrame withSampleTime:(CMTime)currentSampleTime
{
    if (self.renderFrameBlock) {
        self.renderFrameBlock();
    }
    [self numa_processMovieFrame:movieFrame withSampleTime:currentSampleTime];
}

@end
