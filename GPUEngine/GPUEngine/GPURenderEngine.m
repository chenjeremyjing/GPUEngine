//
//  GPURenderEngine.m
//  GPUEngine
//
//  Created by Jeremy Liu on 18/6/28.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "GPURenderEngine.h"
#import "BaseFilterRenderTask.h"
#import "FillFilterRenderTask.h"
#import "MaskRenderTask.h"
#import "FillMaskFilter.h"

@interface GPURenderEngine()

@property (nonatomic, strong) BaseFilterRenderTask *baseRenderTask;

@property (nonatomic, strong) FillFilterRenderTask *fillRendereTask;

@property (nonatomic, strong) MaskRenderTask *maskRenderTask;

@property (nonatomic, strong) GPUImageTwoInputFilter *blendFilter;

@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;

@property (nonatomic, strong) FillMaskFilter *maskFilter;

@property (nonatomic, strong) GPUImageView *gView;

@property (nonatomic, copy) void(^saveVideoHandle)();

@end

@implementation GPURenderEngine

static GPURenderEngine *engine = nil;

+ (instancetype)renderEngine {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[GPURenderEngine alloc] init];
        engine.baseRenderTask = [[BaseFilterRenderTask alloc] init];
        engine.fillRendereTask = [[FillFilterRenderTask alloc] init];
        engine.maskRenderTask = [[MaskRenderTask alloc] init];
        engine.maskFilter = [[FillMaskFilter alloc] init];
        engine.blendFilter = [[NUMAMultiplyBlendFilter alloc] init];
    });
    return engine;
}


//底图
- (void)updateBaseResourceWithImage:(UIImage *)baseImage
{
    self.baseRenderTask.baseTexture = [[GPUImagePicture alloc] initWithImage:baseImage];
    self.baseRenderTask.renderSize = self.baseRenderTask.baseTexture.outputImageSize;
    self.maskRenderTask.colorMaskTexture = self.baseRenderTask.colorMaskfilter;
    [self updateBaseWithTransform:CATransform3DIdentity];
    [self processAll];
}

- (void)updateBaseWithTransform:(CATransform3D)transform
{
    self.baseRenderTask.baseTransform = CATransform3DConcat(transform, [self setContentModeAspectToFitWithSize:self.baseRenderTask.renderSize]);
}

- (void)updateBaseFilterStyleWithFilterStyle:(FilterLineStyleType)filterStyle
{
    self.baseRenderTask.filterStyle = filterStyle;
    [self processAll];
}

- (void)updateBaseFilterLineStyleWithOneAdjustValue:(CGFloat)adjustValue
{
    [self.fillRendereTask updateStyleFilterLineParamValueOne:adjustValue];
}
- (void)updateBaseFilterLineStyleWithSecondAdjustValue:(CGFloat)adjustValue
{
    [self.fillRendereTask updateStyleFilterLineParamValueTwo:adjustValue];
}


//填充
- (void)updateFillResourceWithImage:(UIImage *)fillImage
{
    GPUImagePicture *fillTexture = [[GPUImagePicture alloc] initWithImage:fillImage];
    self.fillRendereTask.fillTexture = fillTexture;
    self.fillRendereTask.renderSize = fillTexture.outputImageSize;
    [self updateFillWithTransform:CATransform3DIdentity];
    [self processAll];

}

- (void)updateFillResourceWithVideoAsset:(AVAsset *)videoAsset
{
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:videoAsset];
    GPUImageMovie *movie = [[GPUImageMovie alloc] initWithPlayerItem:playerItem];
    self.fillRendereTask.fillTexture = movie;    
    self.fillRendereTask.renderSize = videoAsset.naturalSize;
    [self updateFillWithTransform:CATransform3DIdentity];
    [self processAll];

}

- (void)updateFillWithTransform:(CATransform3D)transform
{
    self.fillRendereTask.fillTransform = CATransform3DConcat(transform, [self setContentModeAspectToFitWithSize:self.fillRendereTask.renderSize]);
}

- (void)updateFillCompensationColor:(UIColor *)compensationColor
{
    self.fillRendereTask.compensationColor = compensationColor;
}

- (void)updateFillCompensationColorAlpha:(CGFloat)alpha
{
    self.fillRendereTask.compensationAlpha = alpha;
}

- (void)updateFillFilterStyleWithFilterStyle:(FilterLineStyleType)filterStyle
{
    self.fillRendereTask.filterStyle = filterStyle;
    [self processAll];
}
- (void)updateFillFilterLineStyleWithOneAdjustValue:(CGFloat)adjustValue
{
    [self.fillRendereTask updateStyleFilterLineParamValueOne:adjustValue];
}
- (void)updateFillFilterLineStyleWithSecondAdjustValue:(CGFloat)adjustValue
{
    [self.fillRendereTask updateStyleFilterLineParamValueTwo:adjustValue];
}

- (void)seekToTime:(CMTime)time
{
    [self.fillRendereTask seekToTime:time];
}

//遮罩 文字
- (void)updateTextMaskWithTextImage:(UIImage *)textImage
{
//    self.maskRenderTask.textMaskTexture = [[GPUImagePicture alloc] initWithImage:textImage];
//    [self processAll];

}
- (void)updateTextMaskWithTextView:(UIView *)textView
{
    self.maskRenderTask.textMaskTexture = [[GPUImageUIElement alloc] initWithView:textView];
    [self processAll];
}

//- (void)updateTextMaskWithText:(NSMutableAttributedString *)text
//{
//    self.maskRenderTask.
//}

- (void)updateTextMaskWithTransform:(CATransform3D)transform
{
    self.maskRenderTask.textMaskTransform = transform;
    
}

//遮罩橡皮擦
- (void)updateEraserMaskWithEraserRawData:(GLubyte *)eraserRawData
{
    if (!self.maskRenderTask.eraserMaskTexture) {
        self.maskRenderTask.eraserMaskTexture = [[GPUImageRawDataInput alloc] initWithBytes:eraserRawData size:panelSize];
    }
    else
    {
        [self.maskRenderTask.eraserMaskTexture updateDataFromBytes:eraserRawData size:panelSize];
    }
    
    [self processAll];
}

//遮罩颜色
- (void)updateColorMaskColorAndTolerance:(render_color)colorAndTolerance
{
    self.baseRenderTask.maskColor = colorAndTolerance;
    
}
- (void)setMaskAndFillHidden:(BOOL)isHidden
{
    self.maskRenderTask.eraserMaskHidden = !isHidden;
    self.maskRenderTask.textMaskHidden = !isHidden;
    self.maskRenderTask.colorMaskHidden = NO;
    self.maskFilter.eraserHighlight = !isHidden;
}

- (void)setFillVideoSpeed:(GPUVideoSpeedType)speed
{
    [self.fillRendereTask setVideoSpeed:speed];
}
- (void)setFillVideoStartTime:(CMTime)startTime
{
    [self.fillRendereTask setVideoStartTime:startTime];
}
- (void)setFillVideoEndTime:(CMTime)endTime
{
    [self.fillRendereTask setVideoEndTime:endTime];
}

- (void)exportWithCachePath:(NSString *)cachePath andProcessingBlock:(processingBlock)progressBlock{
    
    if ([self.fillRendereTask.fillTexture isKindOfClass:[GPUImageMovie class]]) {
        
        //移除当前视频
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:cachePath] error:nil];
        
        //视频写入
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:cachePath] size:panelSize];
        _movieWriter.hasAudioTrack = NO;
        _movieWriter.shouldPassthroughAudio = NO;
        [self.blendFilter addTarget:_movieWriter];

        GPUImageMovie *fillMovie = (GPUImageMovie *)self.fillRendereTask.fillTexture;
//        fillMovie.audioEncodingTarget = _movieWriter;
        [fillMovie enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
        [self.fillRendereTask startVideoWritingWithStartHanler:^{
            [_movieWriter startRecording];
        } completionHandler:^{
            [_movieWriter finishRecording];
            [self saveVideoToAlbum:[NSURL fileURLWithPath:cachePath] handler:^{
                progressBlock(1.0);
            }];
        }];
    } else {
        [self processAll];
        [self.blendFilter useNextFrameForImageCapture];
        UIImage *finalImg = [self.blendFilter imageFromCurrentFramebuffer];
        NSData *finalData = UIImagePNGRepresentation(finalImg);
        [finalData writeToURL:[NSURL fileURLWithPath:cachePath] atomically:YES];
    }
    
}

- (void)processAll
{
    
    if (!self.fillRendereTask.fillTexture
        || !self.baseRenderTask.baseTexture
        || !self.maskRenderTask.eraserMaskTexture
        || !self.maskRenderTask.textMaskTexture
        || !self.maskRenderTask.colorMaskTexture) {
        return;
    }
    
    [self.fillRendereTask addTarget:self.maskFilter];
    [self.maskRenderTask addTarget:self.maskFilter];
    [self.baseRenderTask addTarget:self.blendFilter];
    [self.maskFilter addTarget:self.blendFilter];
    [self.blendFilter addTarget:self.gView];
    
    [self.fillRendereTask processAllWithRenderBlock:^(BOOL hasAnimationVideo) {
        NSLog(@"rendering----------");
        [self.baseRenderTask processAllWithRenderBlock:^(BOOL isMovie) {
            
        }];
        [self.maskRenderTask processAllWithRenderBlock:nil];
    }];

//    if (self.fillRendereTask.hasAnimationVideo) {
//        [self.fillRendereTask processAllWithRenderBlock:^(BOOL hasAnimationVideo) {
//            [self.baseRenderTask processAllWithRenderBlock:^(BOOL isMovie) {
//
//            }];
//            [self.maskRenderTask processAllWithRenderBlock:nil];
//        }];
//    } else
//    {
//        if (self.baseRenderTask.hasAnimationVideo) {
//            [self.baseRenderTask processAllWithRenderBlock:^(BOOL hasAnimationVideo) {
//                [self.fillRendereTask processAllWithRenderBlock:^(BOOL hasAnimationVideo) {
//
//                }];
//                [self.maskRenderTask processAllWithRenderBlock:nil];
//            }];
//        } else
//        {
//            [self.baseRenderTask processAllWithRenderBlock:nil];
//            [self.fillRendereTask processAllWithRenderBlock:nil];
//            [self.maskRenderTask processAllWithRenderBlock:nil];
//        }
//    }
//
}

- (void)setRenderView:(GPUImageView *)renderView
{
    self.gView = renderView;
}

- (CATransform3D)setContentModeAspectToFitWithSize:(CGSize)size
{
    double defaultRatio = panelSize.width / panelSize.height;
    
    double ratio = size.width / size.height;
    
    CGFloat scaleX, scaleY;
    
    if (ratio > defaultRatio) {
        scaleX = ratio / defaultRatio;
        scaleY = 1.0;
    } else {
        scaleX = 1.0;
        scaleY = defaultRatio / ratio;
    }
    return CATransform3DMakeScale(scaleX, scaleY, 1);
    
}

- (void)saveVideoToAlbum:(NSURL *)videoPath handler:(void(^)())handler {
    if (videoPath) {
        [self checkPhotoLibraryAuthorityWithCompletionBlock:^{
            _saveVideoHandle = handler;
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([videoPath path])) {
                UISaveVideoAtPathToSavedPhotosAlbum([videoPath path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            }
        }];
    }
}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        if (_saveVideoHandle) {
            _saveVideoHandle(YES);
        }
    } else {
        if (_saveVideoHandle) {
            _saveVideoHandle(NO);
        }
    }
}

- (void)checkPhotoLibraryAuthorityWithCompletionBlock:(void (^)(void))completionBlock {
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus == PHAuthorizationStatusAuthorized) {
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    } else if (authStatus == PHAuthorizationStatusDenied || authStatus == PHAuthorizationStatusRestricted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *authorityAlert = [[UIAlertView alloc] initWithTitle:@"请打开相册的访问权限" message:@"设置-隐私-相册" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [authorityAlert show];
        });
    } else if (authStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            [self checkPhotoLibraryAuthorityWithCompletionBlock:completionBlock];
        }];
    }
}

@end

