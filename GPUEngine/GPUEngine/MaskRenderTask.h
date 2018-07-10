//
//  MaskRenderTask.h
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "GPURenderTask.h"

@interface MaskRenderTask : GPURenderTask

@property (nonatomic, strong) GPUImageRawDataInput *eraserMaskTexture;

@property (nonatomic, strong) GPUImagePicture *textMaskTexture;

@property (nonatomic, strong) GPUImageOutput *colorMaskTexture;

@property (nonatomic, assign) CATransform3D textMaskTransform;

@property (nonatomic, assign) BOOL colorMaskHidden;
@property (nonatomic, assign) BOOL eraserMaskHidden;
@property (nonatomic, assign) BOOL textMaskHidden;


@end
