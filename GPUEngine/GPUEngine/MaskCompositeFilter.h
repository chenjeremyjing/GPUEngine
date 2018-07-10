//
//  MaskCompositeFilter.h
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface MaskCompositeFilter : GPUImageThreeInputFilter
{
    GLint eraserMaskHiddenUniform;
    GLint textMaskHiddenUniform;
    GLint colorMaskHiddenUniform;
}

@property(readwrite, nonatomic) BOOL eraserMaskHidden;
@property(readwrite, nonatomic) BOOL textMaskHidden;
@property(readwrite, nonatomic) BOOL colorMaskHidden;

@end
