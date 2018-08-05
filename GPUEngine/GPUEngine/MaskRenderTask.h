//
//  MaskRenderTask.h
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "GPURenderTask.h"

@interface MaskRenderTask : GPURenderTask

@property (nonatomic)unsigned char * eraseData; //橡皮擦图片地址

@property (nonatomic, strong) UIImage *strokeImg;

@property (nonatomic, assign) CGSize strokeSize;

@property (nonatomic, assign) BOOL isEraser;

@property (nonatomic, strong) GPUImageRawDataInput *eraserMaskTexture;

@property (nonatomic, strong) NSMutableAttributedString *attributeText;

@property (nonatomic, strong) GPUImageUIElement *textMaskTexture;

@property (nonatomic, strong) UIView *attributeTextPanelView;

@property (nonatomic, strong) GPUImageOutput *colorMaskTexture;

@property (nonatomic, assign) CATransform3D textMaskTransform;

@property (nonatomic, assign) BOOL colorMaskHidden;
@property (nonatomic, assign) BOOL eraserMaskHidden;
@property (nonatomic, assign) BOOL textMaskHidden;


@end
