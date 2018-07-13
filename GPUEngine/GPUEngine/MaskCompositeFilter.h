//
//  MaskCompositeFilter.h
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface MaskCompositeFilter : GPUImageFilter
{
    GPUImageFramebuffer *secondInputFramebuffer;
    GPUImageFramebuffer *thirdInputFramebuffer;
    
    GLint filterSecondTextureCoordinateAttribute;
    GLint filterThirdTextureCoordinateAttribute;
    
    GLint filterInputTextureUniform2;
    GLint filterInputTextureUniform3;
    
    GPUImageRotationMode inputRotation2;
    GPUImageRotationMode inputRotation3;
    
    CMTime firstFrameTime, secondFrameTime, thirdFrameTime;
    
    BOOL hasSetFirstTexture, hasReceivedFirstFrame, firstFrameWasVideo, firstFrameCheckDisabled;
    BOOL hasSetSecondTexture, hasReceivedSecondFrame, secondFrameWasVideo, secondFrameCheckDisabled;
    BOOL hasSetThirdTexture, hasReceivedThirdFrame, thirdFrameWasVideo, thirdFrameCheckDisabled;
    
    GLint eraserMaskHiddenUniform;
    GLint textMaskHiddenUniform;
    GLint colorMaskHiddenUniform;
    
}

@property(readwrite, nonatomic) BOOL eraserMaskHidden;
@property(readwrite, nonatomic) BOOL textMaskHidden;
@property(readwrite, nonatomic) BOOL colorMaskHidden;


@end
