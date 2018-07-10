//
//  GPURenterTask.h
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

@interface GPURenderTask : NSObject

- (void)addTarget:(id<GPUImageInput>)target;

- (void)removeAllTarget;

- (void)processAll;


@end
