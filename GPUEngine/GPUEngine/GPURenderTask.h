//
//  GPURenterTask.h
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

typedef void(^RenderBlock)(BOOL hasAnimationVideo);

@interface GPURenderTask : NSObject

@property (nonatomic, assign) BOOL hasAnimationVideo;

- (void)addTarget:(id<GPUImageInput>)target;

- (void)removeAllTarget;

- (void)processAllWithRenderBlock:(RenderBlock)renderBlock;


@end
