//
//  ColorCompensationFilter.m
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "ColorCompensationFilter.h"
NSString *const NumaColorCompensationFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform lowp float color_R;
 uniform lowp float color_G;
 uniform lowp float color_B;
 uniform lowp float color_A;

 void main()
 {
     lowp vec4 c2 = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 c1 = vec4(color_R, color_G, color_B, color_A);
     
     lowp vec4 outputColor;
     
     //     outputColor.r = c1.r + c2.r * c2.a * (1.0 - c1.a);
     //     outputColor.g = c1.g + c2.g * c2.a * (1.0 - c1.a);
     //     outputColor.b = c1.b + c2.b * c2.a * (1.0 - c1.a);
     //     outputColor.a = c1.a + c2.a * (1.0 - c1.a);
     
     lowp float a = c1.a + c2.a * (1.0 - c1.a);
     lowp float alphaDivisor = a + step(a, 0.0); // Protect against a divide-by-zero blacking out things in the output
     
     outputColor.r = (c1.r * c1.a + c2.r * c2.a * (1.0 - c1.a))/alphaDivisor;
     outputColor.g = (c1.g * c1.a + c2.g * c2.a * (1.0 - c1.a))/alphaDivisor;
     outputColor.b = (c1.b * c1.a + c2.b * c2.a * (1.0 - c1.a))/alphaDivisor;
     outputColor.a = a;
     
     gl_FragColor = outputColor;
 }
 );
@implementation ColorCompensationFilter


- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:NumaColorCompensationFragmentShaderString]))
    {
        return nil;
    }
    
    colorR_Uniform = [filterProgram uniformIndex:@"color_R"];
    colorG_Uniform = [filterProgram uniformIndex:@"color_G"];
    colorB_Uniform = [filterProgram uniformIndex:@"color_B"];
    colorAlpha_Uniform = [filterProgram uniformIndex:@"color_A"];
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
- (void)setA:(CGFloat)a {
    _a = a;
    [self setFloat:a forUniform:colorAlpha_Uniform program:filterProgram];
}

@end
