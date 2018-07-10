//
//  ViewController.m
//  GPUEngine
//
//  Created by Jeremy Liu on 18/6/28.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import "GPURenderEngine.h"

typedef NS_ENUM(NSInteger, currentTarget)
{
    currentTargetBase,
    currentTargetFill,
    currentTargetText,
};

@interface ViewController ()
{
    GPUImagePicture *pic;
    GPUImageView *gView;
    UISlider *_videoTimeLine;
}

@property (nonatomic, strong) UISlider *videoTimeLine;
@property (nonatomic, strong) UIButton *colorBtn;
@property (nonatomic, strong) UIButton *styleColorCompensationBtn;
@property (nonatomic, strong) UISlider *styleColorCompensationAlphaSlider;
@property (nonatomic, strong) UISlider *styleFilterSlider1;
@property (nonatomic, strong) UISlider *styleFilterSlider2;


@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) GPUImageAlphaBlendFilter *blendFilter;

@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic, strong) GPUImageTransformFilter *baseTrans;
@property (nonatomic, strong) GPUImageTransformFilter *FillTrans;
@property (nonatomic, strong) GPUImageTransformFilter *textTrans;

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, assign) currentTarget editTarget;

@property (nonatomic, assign) NSInteger speed;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[UIButton appearance] setBackgroundColor:[UIColor lightGrayColor]];
    
    self.editTarget = 0;
    
    [self initSubviews];
    
    [self setupFilters];
    
    
}

- (void)initSubviews
{
    gView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    gView.fillMode = kGPUImageFillModeStretch;
    [self.view addSubview:gView];
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [gView addGestureRecognizer:panGes];
    
    UIPinchGestureRecognizer *pinchGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGes:)];
    [gView addGestureRecognizer:pinchGes];
    
    UIRotationGestureRecognizer *rotateGes = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGes:)];
    [gView addGestureRecognizer:rotateGes];
    
    UIButton *targetSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [targetSwitchBtn setTitle:@"Base" forState:UIControlStateNormal];
    [targetSwitchBtn addTarget:self action:@selector(switchTarget:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:targetSwitchBtn];
    targetSwitchBtn.frame = CGRectMake(0, CGRectGetMaxY(gView.frame), 50, 30);
    
    UIButton *hiddenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [hiddenBtn setTitle:@"hidden" forState:UIControlStateNormal];
    [hiddenBtn addTarget:self action:@selector(hiddenFill:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hiddenBtn];
    hiddenBtn.frame = CGRectMake(0, CGRectGetMaxY(targetSwitchBtn.frame) + 10, 50, 30);
    
    UIButton *speedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [speedBtn setTitle:@"speed" forState:UIControlStateNormal];
    [speedBtn addTarget:self action:@selector(speedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:speedBtn];
    speedBtn.frame = CGRectMake(0, CGRectGetMaxY(hiddenBtn.frame) + 10, 50, 30);
    
    _videoTimeLine = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxY(speedBtn.frame) + 20, CGRectGetMinY(speedBtn.frame), 200, 30)];
    [self.view addSubview:_videoTimeLine];
    _videoTimeLine.minimumValue = 0;
    _videoTimeLine.maximumValue = 1;
    [_videoTimeLine addTarget:self action:@selector(timeLineOffset:) forControlEvents:UIControlEventValueChanged];
    
    _colorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_colorBtn setTitle:@"colorMask" forState:UIControlStateNormal];
    [_colorBtn addTarget:self action:@selector(colorBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_colorBtn];
    _colorBtn.frame = CGRectMake(0, CGRectGetMaxY(speedBtn.frame) + 10, 50, 30);
    _colorBtn.hidden = YES;
    
    UISlider *colorOffsetSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxY(_colorBtn.frame) + 20, CGRectGetMinY(_colorBtn.frame), 200, 30)];
    [self.view addSubview:colorOffsetSlider];
    colorOffsetSlider.minimumValue = -0.1;
    colorOffsetSlider.maximumValue = +0.1;
    [colorOffsetSlider addTarget:self action:@selector(colorOffset:) forControlEvents:UIControlEventValueChanged];
    
    UIButton *styleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [styleBtn setTitle:@"style-Off" forState:UIControlStateNormal];
    [styleBtn addTarget:self action:@selector(style:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:styleBtn];
    styleBtn.frame = CGRectMake(0, CGRectGetMaxY(_colorBtn.frame) + 10, 50, 30);
    styleBtn.selected = NO;
    
    _styleColorCompensationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_styleColorCompensationBtn setTitle:@"white" forState:UIControlStateNormal];
    [_styleColorCompensationBtn addTarget:self action:@selector(colorChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_styleColorCompensationBtn];
    _styleColorCompensationBtn.frame = CGRectMake(0, CGRectGetMaxY(styleBtn.frame) + 10, 50, 30);
    _styleColorCompensationBtn.selected = YES;
    
    _styleColorCompensationAlphaSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxY(styleBtn.frame) + 20, CGRectGetMinY(styleBtn.frame), 200, 30)];
    [self.view addSubview:_styleColorCompensationAlphaSlider];
    _styleColorCompensationAlphaSlider.minimumValue = -0.1;
    _styleColorCompensationAlphaSlider.maximumValue = +0.1;
    [_styleColorCompensationAlphaSlider addTarget:self action:@selector(colorAlpha:) forControlEvents:UIControlEventValueChanged];
    
    _styleFilterSlider1 = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMinX(_styleColorCompensationAlphaSlider.frame), CGRectGetMaxY(_styleColorCompensationAlphaSlider.frame) + 10, 200, 30)];
    [self.view addSubview:_styleFilterSlider1];
    _styleFilterSlider1.minimumValue = -0.1;
    _styleFilterSlider1.maximumValue = +0.1;
    [_styleFilterSlider1 addTarget:self action:@selector(filterValue1:) forControlEvents:UIControlEventValueChanged];
    
    _styleFilterSlider2 = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMinX(_styleFilterSlider1.frame), CGRectGetMaxY(_styleFilterSlider1.frame) + 10, 200, 30)];
    [self.view addSubview:_styleFilterSlider2];
    _styleFilterSlider2.minimumValue = -0.1;
    _styleFilterSlider2.maximumValue = +0.1;
    [_styleFilterSlider2 addTarget:self action:@selector(filterValue2:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)colorAlpha:(UISlider *)sender
{
    
}

- (void)filterValue1:(UISlider *)sender
{
    
}

- (void)filterValue2:(UISlider *)sender
{
    
}

- (void)style:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _styleColorCompensationBtn.hidden = sender.selected;
    _styleFilterSlider1.hidden = sender.selected;
    _styleFilterSlider1.hidden = sender.selected;
    _styleColorCompensationAlphaSlider.hidden = sender.selected;
    [sender setTitle:sender.selected ? @"style-On" : @"style-Off" forState:UIControlStateNormal];

}

- (void)colorChanged:(UIButton *)sender
{
    sender.selected = !sender.selected;
    UIColor *color = sender.selected ? [UIColor whiteColor] : [UIColor blueColor];
    [sender setTitle:sender.selected ? @"white" : @"blue" forState:UIControlStateNormal];
}

- (void)colorBtn:(UIButton *)sender
{
    
}

- (void)colorOffset:(UISlider *)slider
{
    
}

- (void)timeLineOffset:(UISlider *)sender
{
    CGFloat second = sender.value * CMTimeGetSeconds(self.player.currentItem.duration);
    int preferredTimeScale = 1 * NSEC_PER_SEC;
    CMTime currentTime = CMTimeMakeWithSeconds(second, preferredTimeScale);
    [self.player seekToTime:currentTime];
    [self.player play];
}

- (void)hiddenFill:(UIButton *)sender
{
    
}

- (void)speedBtn:(UIButton *)sender
{
    self.speed++;
    if (self.speed > 2) {
        self.speed = 0;
    }
    
    CGFloat speed = self.speed * 2.0;
    
    self.player.rate = speed;
    
}

- (void)switchTarget:(UIButton *)sender
{
    self.editTarget++;
    if (self.editTarget > 2) {
        self.editTarget = 0;
    }
    _colorBtn.hidden = YES;
    switch (self.editTarget) {
        case currentTargetBase:
            [sender setTitle:@"Base" forState:UIControlStateNormal];
            break;
        case currentTargetFill:
            [sender setTitle:@"Fill" forState:UIControlStateNormal];
            break;
        case currentTargetText:
            [sender setTitle:@"Text" forState:UIControlStateNormal];
            _colorBtn.hidden = NO;
            break;
            
        default:
            break;
    }

}

- (void)setupFilters {
    
    pic = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"b"]];
    
    self.baseTrans = [[GPUImageTransformFilter alloc] init];
    self.baseTrans.transform3D = [self setContentModeAspectToFitWithSize:pic.outputImageSize];
    
    self.blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    self.blendFilter.mix = 0.5;
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"a" ofType:@".mp4"]];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    self.player = [[AVPlayer alloc] initWithPlayerItem:item];
    _player.rate = 1.0;
    _player.volume = 0;
    
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        NSLog(@"dssd");
    }
    __weak typeof(self) weakSelf = self;
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        CGFloat duration = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        CGFloat current = CMTimeGetSeconds(weakSelf.player.currentItem.currentTime);
        
        weakSelf.videoTimeLine.value = current / duration;
        
        if (CMTimeGetSeconds(weakSelf.player.currentItem.currentTime) == CMTimeGetSeconds(weakSelf.player.currentItem.duration)) {
            [weakSelf.player pause];
            [weakSelf.player seekToTime:kCMTimeZero];
            [weakSelf.player play];
        }
        
    }];
    
    GPUImageMovie *movie = [[GPUImageMovie alloc] initWithPlayerItem:item];
    movie.runBenchmark = YES;
    movie.playAtActualSpeed = YES;
    
    
    self.FillTrans = [[GPUImageTransformFilter alloc] init];
    self.FillTrans.transform3D = [self setContentModeAspectToFitWithSize:pic.outputImageSize];
    
    [pic addTarget:self.baseTrans];
    [movie addTarget:self.FillTrans];
    [self.FillTrans addTarget:self.blendFilter atTextureLocation:0];
    [self.baseTrans addTarget:self.blendFilter atTextureLocation:1];
    
    [pic processImage];
    
    [self.blendFilter addTarget:gView];
    
    [movie startProcessing];
    movie.renderFrameBlock = ^{
        [pic processImage];
    };
    
    [self.player play];
}

- (void)pan:(UIPanGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:sender.view];
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        self.lastPoint = point;
    }
    
    
    switch (self.editTarget) {
        case currentTargetBase:
            {
                CATransform3D transform = self.baseTrans.transform3D;
                transform.m41 = transform.m41 + (point.x - self.lastPoint.x)/self.view.frame.size.width*2;
                transform.m42 = transform.m42 + (point.y - self.lastPoint.y)/self.view.frame.size.width*2;
                self.baseTrans.transform3D = transform;
                
            }
            break;
        case currentTargetFill:
        {
            CATransform3D transform = self.FillTrans.transform3D;
            transform.m41 = transform.m41 + (point.x - self.lastPoint.x)/self.view.frame.size.width*2;
            transform.m42 = transform.m42 + (point.y- self.lastPoint.y)/self.view.frame.size.width*2;
            self.FillTrans.transform3D = transform;
        }
            break;
        case currentTargetText:
            {
                CATransform3D transform = self.textTrans.transform3D;
                transform.m41 = transform.m41 + (point.x - self.lastPoint.x)/self.view.frame.size.width*2;
                transform.m42 = transform.m42 + (point.y - self.lastPoint.y)/self.view.frame.size.width*2;
                self.textTrans.transform3D = transform;
            }
            break;
            
        default:
            break;
    }
    
    

    self.lastPoint = point;

    
}

- (void)pinchGes:(UIPinchGestureRecognizer *)sender
{
    switch (self.editTarget) {
        case currentTargetBase:
            self.baseTrans.transform3D = CATransform3DScale(self.baseTrans.transform3D, sender.scale, sender.scale, 1);
            break;
        case currentTargetFill:
            self.FillTrans.transform3D = CATransform3DScale(self.FillTrans.transform3D, sender.scale, sender.scale, 1);
            break;
        case currentTargetText:
            self.textTrans.transform3D = CATransform3DScale(self.textTrans.transform3D, sender.scale, sender.scale, 1);
            break;
            
        default:
            break;
    }
    sender.scale = 1.0f;
}

- (void)rotateGes:(UIRotationGestureRecognizer *)sender
{
    switch (self.editTarget) {
        case currentTargetBase:
            self.baseTrans.transform3D = CATransform3DRotate(self.baseTrans.transform3D, sender.rotation, 0, 0, 1);
            break;
        case currentTargetFill:
            self.FillTrans.transform3D = CATransform3DRotate(self.FillTrans.transform3D, sender.rotation, 0, 0, 1);
            break;
        case currentTargetText:
            self.textTrans.transform3D = CATransform3DRotate(self.textTrans.transform3D, sender.rotation, 0, 0, 1);
            break;
            
        default:
            break;
    }
    sender.rotation = 0.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CATransform3D)setContentModeAspectToFitWithSize:(CGSize)size
{
    double defaultRatio = gView.frame.size.width / gView.frame.size.height;
    
    double ratio = size.width / size.height;
    
    
    CGFloat scaleX, scaleY;
    
    if (ratio > defaultRatio) {
        scaleX = 1.0;
        scaleY = defaultRatio / ratio;
    } else {
        scaleX = ratio / defaultRatio;
        scaleY = 1.0;
    }
    return CATransform3DMakeScale(scaleX, scaleY, 1);
    
}

@end