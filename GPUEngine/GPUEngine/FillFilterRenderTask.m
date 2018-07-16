//
//  FillFilterRenderTask.m
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "FillFilterRenderTask.h"

@interface FillFilterRenderTask()

//填充涂层变形滤镜
@property (nonatomic, strong) GPUImageTransformFilter *fillTransFilter;

@property (nonatomic, strong) FilterLineStyleHelper *filterLinerStyleHelper;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, assign) CMTime startTime;

@property (nonatomic, assign) CMTime endTime;

@property (nonatomic, copy) RenderBlock renderBlock;


@end

@implementation FillFilterRenderTask

#pragma mark -- Common Methods
- (void)addTarget:(id<GPUImageInput>)target {
    [self.filterLinerStyleHelper.sufixFilter addTarget:target];
}

- (void)processAllWithRenderBlock:(RenderBlock)renderBlock {
    self.renderBlock = renderBlock;
    __weak typeof(self) weakSelf = self;
    
    if ([weakSelf.fillTexture isKindOfClass:[GPUImagePicture class]]) {
        GPUImagePicture *pic = (GPUImagePicture *)weakSelf.fillTexture;
        [pic processImage];
    }
    
    [self.filterLinerStyleHelper startProcessWithRenderBlock:^(BOOL hasAnimationVideo) {
        if ([weakSelf.fillTexture isKindOfClass:[GPUImageMovie class]]) {
            weakSelf.renderBlock(YES);
            GPUImageMovie *movie = (GPUImageMovie *)weakSelf.fillTexture;
            if (weakSelf.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
                [movie startProcessing];
                [weakSelf.player play];
            }
        } else {
            weakSelf.renderBlock(hasAnimationVideo);
            GPUImagePicture *pic = (GPUImagePicture *)weakSelf.fillTexture;
            [pic processImage];
        }
    }];
    
}

- (void)setVideoSpeed:(GPUVideoSpeedType)speed{
    switch (speed) {
        case GPUVideo2SpeedAccelerateType:
            self.player.rate = 2.0;
            break;
        case GPUVideoSpeedNormalType:
            self.player.rate = 1.0;
            break;
        case GPUVideo2SpeedDecelerateType:
            self.player.rate = 0.5;
            break;
            
        default:
            break;
    }
}

- (void)setVideoStartTime:(CMTime)startTime;
{
    self.startTime = startTime;
    [self seekToTime:startTime];
}

- (void)setVideoEndTime:(CMTime)endTime
{
    self.endTime = endTime;
    [self seekToTime:endTime];
}

- (void)seekToTime:(CMTime)time {
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            [self.player play];
        }
    }];
}

#pragma mark -- Setter && Getter
- (void)setFillTexture:(GPUImageOutput *)fillTexture {
    [_fillTexture removeAllTargets];
    _fillTexture = fillTexture;
    if ([fillTexture isKindOfClass:[GPUImageMovie class]]) {
        GPUImageMovie *movie = (GPUImageMovie *)fillTexture;
        [self.player replaceCurrentItemWithPlayerItem:movie.playerItem];
        self.startTime = kCMTimeZero;
        self.endTime = self.player.currentItem.duration;
    }
    [_fillTexture addTarget:self.fillTransFilter];
    [self.fillTransFilter addTarget:self.filterLinerStyleHelper.prefixFilter];
}

- (void)setFilterStyle:(FilterLineStyleType)filterStyle {
    _filterStyle = filterStyle;
    [self.fillTransFilter removeAllTargets];
    self.filterLinerStyleHelper.filterStyle = filterStyle;
    [self.fillTransFilter addTarget:self.filterLinerStyleHelper.prefixFilter];
}

- (void)setFillTransform:(CATransform3D)fillTransform {
    _fillTransform = fillTransform;
    self.fillTransFilter.transform3D = fillTransform;
}

- (void)setCompensationColor:(UIColor *)compensationColor {
    _compensationColor = compensationColor;
    self.filterLinerStyleHelper.compensationColor = compensationColor;
}

- (void)setCompensationAlpha:(CGFloat)compensationAlpha {
    _compensationAlpha  = compensationAlpha;
    self.filterLinerStyleHelper.compensationAlpha = compensationAlpha;
}

- (GPUImageTransformFilter *)fillTransFilter {
    if (!_fillTransFilter) {
        _fillTransFilter = [[GPUImageTransformFilter alloc] init];
    }
    return _fillTransFilter;
}

- (FilterLineStyleHelper *)filterLinerStyleHelper {
    if (!_filterLinerStyleHelper) {
        _filterLinerStyleHelper = [FilterLineStyleHelper filterLineWithStyle:FilterLineCartoonStyleType];
        
    }
    return _filterLinerStyleHelper;
}

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
        _player.volume = 0;
        __weak typeof (self)weakSelf = self;
        [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            if (CMTimeGetSeconds(weakSelf.player.currentItem.currentTime) == CMTimeGetSeconds(weakSelf.endTime)) {
                [weakSelf.player seekToTime:weakSelf.startTime];
                [weakSelf.player play];
            }
        }];
    }
    return _player;
}

- (BOOL)hasAnimationVideo {
    return self.filterLinerStyleHelper.hasAnimationVideo || [self.fillTexture isKindOfClass:[GPUImageMovie class]];
}

@end
