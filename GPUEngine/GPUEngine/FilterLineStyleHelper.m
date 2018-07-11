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

@end

@implementation FilterLineStyleHelper

#pragma mark -- Init methods
+ (instancetype)filterLineWithStyle:(FilterLineStyleType)filterStyle
{
    FilterLineStyleHelper *filterStyleHelper = [[FilterLineStyleHelper alloc] init];
    filterStyleHelper.filterStyle = FilterLineCityStyleType;
    return filterStyleHelper;
}

#pragma mark -- Setter && Getter

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
        _player.volume = 0;
        __weak typeof (self)weakSelf = self;
        [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
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
            GPUImageSaturationFilter *saturationfilter = [[GPUImageSaturationFilter alloc] init];
            GPUImageContrastFilter *contrastfilter = [[GPUImageContrastFilter alloc] init];
            self.colorCompensationFilter = [[ColorCompensationFilter alloc] init];

            [saturationfilter addTarget:contrastfilter];
            
            //动态视频混合滤镜
            self.animationBlendFilter = [[GPUImageNormalBlendFilter alloc]init];
            [contrastfilter addTarget:self.animationBlendFilter atTextureLocation:0];
            
            self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"a" ofType:@".mp4"]]];
            
            //模拟滤镜链
            self.firstAdjustFilter = saturationfilter;
            self.secondAdjustFilter = contrastfilter;
            self.prefixFilter = saturationfilter;
            self.secondAdjustFilter = contrastfilter;
        }
            break;
        case FilterLineCityStyleType:
        {
            self.colorCompensationFilter = [[ColorCompensationFilter alloc] init];
            GPUImageSaturationFilter *saturationfilter = [[GPUImageSaturationFilter alloc] init];
            GPUImageContrastFilter *contrastfilter = [[GPUImageContrastFilter alloc] init];
            self.animationBlendFilter = [[GPUImageNormalBlendFilter alloc]init];
            [saturationfilter addTarget:contrastfilter];
            [contrastfilter addTarget:self.animationBlendFilter atTextureLocation:0];
            self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"a" ofType:@".mp4"]]];
            
            //模拟滤镜链
            self.firstAdjustFilter = saturationfilter;
            self.secondAdjustFilter = contrastfilter;
            self.prefixFilter = saturationfilter;
            self.secondAdjustFilter = contrastfilter;

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
    
    [self.player pause];
    [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    [self.player play];
}

- (void)setCompensationColor:(UIColor *)compensationColor {
    _compensationColor = compensationColor;
}

- (void)setCompensationAlpha:(CGFloat)compensationAlpha {
    _compensationAlpha = compensationAlpha;
}

- (GPUImageFilter *)sufixFilter {
    return self.colorCompensationFilter;
}



@end
