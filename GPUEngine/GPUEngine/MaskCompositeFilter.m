//
//  MaskCompositeFilter.m
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "MaskCompositeFilter.h"

NSString *const kGPUImageMaskGenerateFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 varying highp vec2 textureCoordinate3;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 
 uniform lowp float eraserMaskHidden;
 uniform lowp float textMaskHidden;
 uniform lowp float colorMaskHidden;

 
 void main()
 {
     lowp vec4 eraserMask = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 textMask = texture2D(inputImageTexture2, textureCoordinate2);
     lowp vec4 colorMask = texture2D(inputImageTexture3, textureCoordinate3);
     
     lowp vec4 resultColor = vec4(0.0);
     
     if (eraserMaskHidden == 1.0)
     {
         eraserMask.a = 0.0;
     }
     if (textMaskHidden == 1.0)
     {
         textMask.a = 0.0;
     }
     if (colorMaskHidden == 1.0)
     {
         colorMask.a = 0.0;
     }
     
//     if (eraserMask.a == 0.0 && textMask.a == 0.0 && colorMask.a == 0.0)
//     {
//         resultColor.a = 0.0;
//     }
//     else
//     {
     resultColor.a = eraserMask.a;
     if (textMask.a < resultColor.a)
     {
         resultColor.a = textMask.a;
     }
     if (colorMask.a < resultColor.a)
     {
         resultColor.a = colorMask.a;
     }
//     }
     
     gl_FragColor = resultColor;
 }
 );


@implementation MaskCompositeFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageMaskGenerateFragmentShaderString]))
    {
        return nil;
    }
    
    eraserMaskHiddenUniform = [filterProgram uniformIndex:@"eraserMaskHidden"];
    textMaskHiddenUniform = [filterProgram uniformIndex:@"textMaskHidden"];
    colorMaskHiddenUniform = [filterProgram uniformIndex:@"colorMaskHidden"];
    self.colorMaskHidden = YES;
    self.eraserMaskHidden = YES;
    self.textMaskHidden = YES;
    return self;
}

- (void)setEraserMaskHidden:(BOOL)eraserMaskHidden {
    _eraserMaskHidden = eraserMaskHidden;
    [self setFloat:eraserMaskHidden forUniform:eraserMaskHiddenUniform program:filterProgram];
}

- (void)setTextMaskHidden:(BOOL)textMaskHidden {
    _textMaskHidden = textMaskHidden;
    [self setFloat:textMaskHidden forUniform:textMaskHiddenUniform program:filterProgram];
}

- (void)setColorMaskHidden:(BOOL)colorMaskHidden {
    _colorMaskHidden = colorMaskHidden;
    [self setFloat:colorMaskHidden forUniform:colorMaskHiddenUniform program:filterProgram];
}

@end
