//
//  FillMaskFilter.h
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface FillMaskFilter : GPUImageTwoInputFilter

{
    GLint eraserHighlightUniform;
}

@property(readwrite, nonatomic) BOOL eraserHighlight;


@end
