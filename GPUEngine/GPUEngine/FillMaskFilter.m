//
//  FillMaskFilter.m
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "FillMaskFilter.h"

NSString *const kGPUImageMaskBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform lowp float eraserHighlight;
 
 
 void main()
 {
     lowp vec4 fillColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 maskColor = texture2D(inputImageTexture2, textureCoordinate2);
     
     lowp vec4 resultColor = fillColor * (1.0 - maskColor.a);
          
     if (eraserHighlight == 1.0)
     {
         if (maskColor.a > 0.0)
         {
             lowp vec4 highlightColor = vec4(1.0,0.0,0.0,1.0);
             resultColor = highlightColor;
         } else {
             resultColor = vec4(0.0);
         }
         
     }
     
     gl_FragColor = resultColor;
 }
 );



@implementation FillMaskFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageMaskBlendFragmentShaderString]))
    {
        return nil;
    }
    
    eraserHighlightUniform = [filterProgram uniformIndex:@"eraserHighlight"];

    self.eraserHighlight = NO;
    return self;
}

- (void)setEraserHighlight:(BOOL)eraserHighlight
{
    _eraserHighlight = eraserHighlight;
    [self setFloat:eraserHighlight forUniform:eraserHighlightUniform program:filterProgram];
}

@end
