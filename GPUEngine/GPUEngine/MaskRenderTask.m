
//
//  MaskRenderTask.m
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "MaskRenderTask.h"
#import "MaskCompositeFilter.h"

@interface MaskRenderTask()

//遮罩混合滤镜 （橡皮擦，颜色抠图，文字轮廓 三层遮罩的混合）
@property (nonatomic, strong) MaskCompositeFilter *compositeFilter;

//文字遮罩变形滤镜
@property (nonatomic, strong) GPUImageTransformFilter *textTransFilter;

@end

#define colorMaskTextureLocation 0      //颜色抠图轮廓遮罩所在纹理下标
#define textMaskTextureLocation 1       //文字轮廓遮罩所在纹理下标
#define eraserMaskTextureLocation 2     //橡皮擦轮廓遮罩所在纹理下标

@implementation MaskRenderTask

#pragma mark -- Common Methods
- (void)addTarget:(id<GPUImageInput>)target {
    [self.compositeFilter addTarget:target];
}

#pragma mark -- Setter && Getter

- (void)setTextMaskTexture:(GPUImagePicture *)textMaskTexture {
    [_textMaskTexture removeAllTargets];
    
    _textMaskTexture = textMaskTexture;
    [_textMaskTexture addTarget:self.textTransFilter];
    [_textTransFilter addTarget:self.compositeFilter atTextureLocation:textMaskTextureLocation];
    
}

- (void)setEraserMaskTexture:(GPUImageRawDataInput *)eraserMaskTexture {
    [_eraserMaskTexture removeAllTargets];
    
    _eraserMaskTexture = eraserMaskTexture;
    [_eraserMaskTexture addTarget:self.compositeFilter atTextureLocation:eraserMaskTextureLocation];
}

- (void)setColorMaskTexture:(GPUImageOutput *)colorMaskTexture {
    [_colorMaskTexture removeAllTargets];
    
    _colorMaskTexture = colorMaskTexture;
    [_colorMaskTexture addTarget:self.compositeFilter atTextureLocation:colorMaskTextureLocation];
}

- (void)setColorMaskHidden:(BOOL)colorMaskHidden {
    _colorMaskHidden = colorMaskHidden;
    self.compositeFilter.colorMaskHidden = _colorMaskHidden;
}

- (void)setTextMaskHidden:(BOOL)textMaskHidden {
    _textMaskHidden = textMaskHidden;
    self.compositeFilter.textMaskHidden = _textMaskHidden;
}

- (void)setEraserMaskHidden:(BOOL)eraserMaskHidden {
    _eraserMaskHidden = eraserMaskHidden;
    self.compositeFilter.eraserMaskHidden = _eraserMaskHidden;
}

@end
