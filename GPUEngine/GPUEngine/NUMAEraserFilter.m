//
//  NUMAEraserFilter.m
//  GPUEngine
//
//  Created by BeautyHZ on 2018/7/26.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "NUMAEraserFilter.h"

NSString *const kNUMAEraserFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform lowp float isEraser;
 uniform lowp float eraserOpacity;
 uniform lowp float strokeSize;
 uniform lowp float position;
 
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 eraserColor = texture2D(inputImageTexture2, textureCoordinate2);
     
     if ((textureColor.r >= color_R - offset && textureColor.r <= color_R + offset) && (textureColor.g >= color_G - offset && textureColor.g <= color_G + offset) && (textureColor.b >= color_B - offset && textureColor.b <= color_B + offset))
     {
         resultColor.a = 1.0;
     }
     
     gl_FragColor = resultColor;
 }
 );
@implementation NUMAEraserFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kNUMAEraserFragmentShaderString]))
    {
        return nil;
    }
    
    isEraser_Uniform = [filterProgram uniformIndex:@"isEraser"];
    eraserOpacity_Uniform = [filterProgram uniformIndex:@"eraserOpacity"];
    strokeSize_Uniform = [filterProgram uniformIndex:@"strokeSize"];
    position_Uniform = [filterProgram uniformIndex:@"position"];
    
    return self;
}


- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        [secondInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 2);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [secondInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform2, 3);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(filterSecondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation2]);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    [secondInputFramebuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)setIsEraser:(BOOL)isEraser {
    _isEraser = isEraser;
}

- (void)setEraserOpacity:(CGFloat)eraserOpacity {
    _eraserOpacity = eraserOpacity;
}

- (void)setStrokeSize:(CGFloat)strokeSize {
    _strokeSize = strokeSize;
}

- (void)setPosition:(CGPoint)position {
    _position = position;
}


@end
