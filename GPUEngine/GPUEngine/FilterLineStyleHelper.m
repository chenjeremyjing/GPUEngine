//
//  FilterLineStyleHelper.m
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "FilterLineStyleHelper.h"
#import "ColorCompensationFilter.h"

@interface FilterLineStyleHelper()

//滤镜风格 纯色补偿滤镜
@property (nonatomic, strong) ColorCompensationFilter *colorCompensationFilter;

//风格滤镜的视频播放器
@property (nonatomic, strong) AVPlayer *player;

//
@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) GPUImageMovie *animtaionMovie;

@property (nonatomic, strong) GPUImageTwoInputFilter *animationBlendFilter;

@property (nonatomic, copy) filterLineStyleRenderBlock filterLineRenderBlock;

@end

@implementation FilterLineStyleHelper

#pragma mark -- Init methods
+ (instancetype)filterLineWithStyle:(FilterLineStyleType)filterStyle
{
    FilterLineStyleHelper *filterStyleHelper = [[FilterLineStyleHelper alloc] init];
    filterStyleHelper.filterStyle = filterStyle;
    return filterStyleHelper;
}

- (void)startProcessWithRenderBlock:(filterLineStyleRenderBlock)renderBlock
{
    self.filterLineRenderBlock = renderBlock;
    if (!_animtaionMovie) {
        self.filterLineRenderBlock(NO);
        return;
    }
    
    if (_player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
        [_player play];
    }
    
}

#pragma mark -- Setter && Getter

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
        _player.volume = 0;
        __weak typeof (self)weakSelf = self;
        [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            NSLog(@"playing:styleWithVideo_____%d", weakSelf.filterStyle);
            if (CMTimeGetSeconds(weakSelf.player.currentItem.currentTime) == CMTimeGetSeconds(weakSelf.player.currentItem.duration)) {
                [weakSelf.player seekToTime:kCMTimeZero];
                [weakSelf.player play];
            }
        }];
    }
    return _player;
}

- (void)setFilterStyle:(FilterLineStyleType)filterStyle {
    _filterStyle = filterStyle;
    switch (filterStyle) {
        case FilterLineCartoonStyleType:
        {
            //风格滤镜脸所需滤镜
            //饱和度
            GPUImageSaturationFilter *saturationfilter = [[GPUImageSaturationFilter alloc] init];
            //对比度
            GPUImageContrastFilter *contrastfilter = [[GPUImageContrastFilter alloc] init];
            //颜色补偿
            self.colorCompensationFilter = [[ColorCompensationFilter alloc] init];
            self.colorCompensationFilter.r = 1.0;
            self.colorCompensationFilter.g = 1.0;
            self.colorCompensationFilter.b = 1.0;
            self.colorCompensationFilter.a = 0.0;

            [saturationfilter addTarget:contrastfilter];
            
            //动态视频混合滤镜
            self.animationBlendFilter = [[NUMAMultiplyBlendFilter alloc] init];
            [contrastfilter addTarget:self.colorCompensationFilter atTextureLocation:0];
            
//            self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"baseV" ofType:@".mp4"]]];
            self.hasAnimationVideo = NO;
            
            //模拟滤镜链
            self.firstAdjustFilter = saturationfilter;
            self.secondAdjustFilter = contrastfilter;
            self.prefixFilter = saturationfilter;
            self.sufixFilter = contrastfilter;
        }
            break;
        case FilterLineCityStyleType:
        {
            //颜色补偿
            self.colorCompensationFilter = [[ColorCompensationFilter alloc] init];
            self.colorCompensationFilter.r = 1.0;
            self.colorCompensationFilter.g = 1.0;
            self.colorCompensationFilter.b = 1.0;
            self.colorCompensationFilter.a = 0.0;
            
            //饱和度
            GPUImageSaturationFilter *saturationfilter = [[GPUImageSaturationFilter alloc] init];
            //对比度
            GPUImageContrastFilter *contrastfilter = [[GPUImageContrastFilter alloc] init];
            self.animationBlendFilter = [[NUMAMultiplyBlendFilter alloc]init];
            [saturationfilter addTarget:contrastfilter];
            [contrastfilter addTarget:self.colorCompensationFilter atTextureLocation:0];
//            self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"fillV" ofType:@".mp4"]]];
            
            //模拟滤镜链
            self.firstAdjustFilter = saturationfilter;
            self.secondAdjustFilter = contrastfilter;
            self.prefixFilter = saturationfilter;
            self.sufixFilter = contrastfilter;
            self.hasAnimationVideo = NO;

        }
            break;
            
        default:
            break;
    }
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    _playerItem = playerItem;
    
    [self.animtaionMovie removeAllTargets];
    self.animtaionMovie = [[GPUImageMovie alloc] initWithPlayerItem:playerItem];
    
    self.animtaionMovie.runBenchmark = YES;
    self.animtaionMovie.playAtActualSpeed = YES;
    [self.animtaionMovie addTarget:self.animationBlendFilter atTextureLocation:1];
    [self.animationBlendFilter addTarget:self.colorCompensationFilter];
    [self.animtaionMovie startProcessing];
    __weak typeof(self)weakSelf = self;
    self.animtaionMovie.renderFrameBlock = ^{
        if (weakSelf.filterLineRenderBlock) {
            NSLog(@"rendering:styleWithVideo%d", weakSelf.filterStyle);
            weakSelf.filterLineRenderBlock(YES);
        }
    };
    
    [self.player pause];
    [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    
    //更新滤镜链最新添加的播放器和视频
    [GPURenderEngine renderEngine].lastMovie = self.animtaionMovie;
    [GPURenderEngine renderEngine].lastVideoPlayer = self.player;
}

- (void)setCompensationColor:(UIColor *)compensationColor {
    _compensationColor = compensationColor;
    CGFloat r = 0.0;
    CGFloat g = 0.0;
    CGFloat b = 0.0;
    CGFloat a = 0.0;
    BOOL parserColor = [compensationColor getRed:&r green:&g blue:&b alpha:&a];
    if (parserColor) {
        self.colorCompensationFilter.r = r;
        self.colorCompensationFilter.g = g;
        self.colorCompensationFilter.b = b;
        self.colorCompensationFilter.a = a;
    }
}

- (void)setCompensationAlpha:(CGFloat)compensationAlpha {
    _compensationAlpha = compensationAlpha;
    self.colorCompensationFilter.a = compensationAlpha;
}

- (GPUImageFilter *)sufixFilter {
    return self.colorCompensationFilter;
}



@end
