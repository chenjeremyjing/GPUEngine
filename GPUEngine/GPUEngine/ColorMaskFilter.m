//
//  ColorMaskFilter.m
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "ColorMaskFilter.h"


NSString *const kGPUImageColorMaskFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform lowp float color_R;
 uniform lowp float color_G;
 uniform lowp float color_B;
 uniform lowp float offset;
 
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     lowp vec4 resultColor = vec4(0.0);

     if ((textureColor.r >= color_R - offset && textureColor.r <= color_R + offset) && (textureColor.g >= color_G - offset && textureColor.g <= color_G + offset) && (textureColor.b >= color_B - offset && textureColor.b <= color_B + offset))
     {
         resultColor.a = 1.0;
     }
     
     gl_FragColor = resultColor;
 }
 );

@implementation ColorMaskFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageColorMaskFragmentShaderString]))
    {
        return nil;
    }
    
    colorR_Uniform = [filterProgram uniformIndex:@"color_R"];
    colorG_Uniform = [filterProgram uniformIndex:@"color_G"];
    colorB_Uniform = [filterProgram uniformIndex:@"color_B"];
    offset_Uniform = [filterProgram uniformIndex:@"offset"];
    return self;
}

- (void)setR:(CGFloat)r
{
    _r = r;
    [self setFloat:_r forUniform:colorR_Uniform program:filterProgram];
}

- (void)setB:(CGFloat)b
{
    _b = b;
    [self setFloat:_b forUniform:colorR_Uniform program:filterProgram];
}

- (void)setG:(CGFloat)g
{
    _g = g;
    [self setFloat:_g forUniform:colorR_Uniform program:filterProgram];
}
- (void)setOffset:(CGFloat)offset {
    _offset = offset;
    [self setFloat:offset forUniform:offset_Uniform program:filterProgram];
}

@end
