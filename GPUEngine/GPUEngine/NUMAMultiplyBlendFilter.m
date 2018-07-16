//
//  NUMAMultiplyBlendFilter.m
//  GPUEngine
//
//  Created by BeautyHZ on 2018/7/16.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "NUMAMultiplyBlendFilter.h"

NSString *const kNUMAMultiplyBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     lowp vec4 base = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 overlayer = texture2D(inputImageTexture2, textureCoordinate2);
     
     gl_FragColor = overlayer * base;
 }
 );

@implementation NUMAMultiplyBlendFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kNUMAMultiplyBlendFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end
