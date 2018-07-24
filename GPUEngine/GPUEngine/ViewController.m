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
#import "ColorMaskFilter.h"
#import "MaskMixFilter.h"

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
    
    GPUImagePicture *mask1;
    GPUImageRawDataInput *mask2;
    GPUImagePicture *mask3;
}

@property (nonatomic)unsigned char * eraseData; //橡皮擦图片地址

@property (nonatomic, strong) UISlider *videoTimeLine;
@property (nonatomic, strong) UIButton *colorMaskBtn;
@property (nonatomic, strong) UIButton *styleSwithchBtn;
@property (nonatomic, strong) UIButton *styleColorCompensationBtn;
@property (nonatomic, strong) UISlider *styleColorCompensationAlphaSlider;
@property (nonatomic, strong) UISlider *styleFilterSlider1;
@property (nonatomic, strong) UISlider *styleFilterSlider2;


@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) GPUImageTwoInputFilter *blendFilter;

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
    [self resetEraseData];
    
    self.view.backgroundColor = [UIColor greenColor];
    
    [[UIButton appearance] setBackgroundColor:[UIColor lightGrayColor]];
    
    self.editTarget = 0;
    
    [self initSubviews];
    
    [self setupFilters];
    
    
}

- (void)initSubviews
{
    gView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    gView.fillMode = kGPUImageFillModeStretch;
    gView.backgroundColor = [UIColor clearColor];
    gView.opaque = NO;
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
    targetSwitchBtn.frame = CGRectMake(0, CGRectGetMaxY(gView.frame), 80, 30);
    
    UIButton *hiddenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [hiddenBtn setTitle:@"hidden" forState:UIControlStateNormal];
    [hiddenBtn addTarget:self action:@selector(hiddenFill:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hiddenBtn];
    hiddenBtn.frame = CGRectMake(0, CGRectGetMaxY(targetSwitchBtn.frame) + 10, 80, 30);
    
    UIButton *speedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [speedBtn setTitle:@"speed" forState:UIControlStateNormal];
    [speedBtn addTarget:self action:@selector(speedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:speedBtn];
    speedBtn.frame = CGRectMake(0, CGRectGetMaxY(hiddenBtn.frame) + 10, 80, 30);
    
    _videoTimeLine = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(speedBtn.frame) + 20, CGRectGetMinY(speedBtn.frame), 200, 30)];
    [self.view addSubview:_videoTimeLine];
    _videoTimeLine.minimumValue = 0;
    _videoTimeLine.maximumValue = 1;
    [_videoTimeLine addTarget:self action:@selector(timeLineOffset:) forControlEvents:UIControlEventValueChanged];
    
    _colorMaskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_colorMaskBtn setTitle:@"colorMask" forState:UIControlStateNormal];
    [_colorMaskBtn addTarget:self action:@selector(colorMask:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_colorMaskBtn];
    _colorMaskBtn.frame = CGRectMake(0, CGRectGetMaxY(speedBtn.frame) + 10, 80, 30);
    
    UISlider *colorOffsetSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_colorMaskBtn.frame) + 20, CGRectGetMinY(_colorMaskBtn.frame), 200, 30)];
    [self.view addSubview:colorOffsetSlider];
    colorOffsetSlider.minimumValue = -0.1;
    colorOffsetSlider.maximumValue = +0.1;
    [colorOffsetSlider addTarget:self action:@selector(colorOffset:) forControlEvents:UIControlEventValueChanged];
    
    UIButton *styleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [styleBtn setTitle:@"style-Off" forState:UIControlStateNormal];
    [styleBtn addTarget:self action:@selector(style:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:styleBtn];
    styleBtn.frame = CGRectMake(0, CGRectGetMaxY(_colorMaskBtn.frame) + 10, 80, 30);
    styleBtn.selected = NO;
    
    [_styleSwithchBtn setTitle:@"style1" forState:UIControlStateNormal];
    [_styleSwithchBtn addTarget:self action:@selector(styleSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_styleSwithchBtn];
    _styleSwithchBtn.frame = CGRectMake(0, CGRectGetMaxY(styleBtn.frame) + 10, 80, 30);
    _styleSwithchBtn.selected = NO;
    
    _styleColorCompensationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_styleColorCompensationBtn setTitle:@"white" forState:UIControlStateNormal];
    [_styleColorCompensationBtn addTarget:self action:@selector(colorChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_styleColorCompensationBtn];
    _styleColorCompensationBtn.frame = CGRectMake(0, CGRectGetMaxY(styleBtn.frame) + 10, 80, 30);
    _styleColorCompensationBtn.selected = YES;
    
    _styleColorCompensationAlphaSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_styleColorCompensationBtn.frame) + 20, CGRectGetMinY(_styleColorCompensationBtn.frame), 200, 30)];
    [self.view addSubview:_styleColorCompensationAlphaSlider];
    _styleColorCompensationAlphaSlider.minimumValue = -0.1;
    _styleColorCompensationAlphaSlider.maximumValue = +0.1;
    [_styleColorCompensationAlphaSlider addTarget:self action:@selector(colorAlpha:) forControlEvents:UIControlEventValueChanged];
    
    _styleFilterSlider1 = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(styleBtn.frame) + 20, CGRectGetMinY(styleBtn.frame), 100, 30)];
    [self.view addSubview:_styleFilterSlider1];
    _styleFilterSlider1.minimumValue = -0.1;
    _styleFilterSlider1.maximumValue = +0.1;
    [_styleFilterSlider1 addTarget:self action:@selector(filterValue1:) forControlEvents:UIControlEventValueChanged];
    
    _styleFilterSlider2 = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_styleFilterSlider1.frame) + 20, CGRectGetMinY(_styleFilterSlider1.frame), 100, 30)];
    [self.view addSubview:_styleFilterSlider2];
    _styleFilterSlider2.minimumValue = -0.1;
    _styleFilterSlider2.maximumValue = +0.1;
    [_styleFilterSlider2 addTarget:self action:@selector(filterValue2:) forControlEvents:UIControlEventValueChanged];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setTitle:@"SAVE" forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    saveBtn.bounds = CGRectMake(0, 0, 80, 30);
    saveBtn.center = CGPointMake(self.view.bounds.size.width / 2, CGRectGetMaxY(self.view.frame) - 100);
    saveBtn.selected = NO;
    
}

- (void)save:(UIButton *)sender
{
    [[GPURenderEngine renderEngine] exportWithCachePath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test.mp4"] andProcessingBlock:^(CGFloat progress) {
        NSLog(@"____save____progress:%f", progress);
    }];
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

- (void)styleSwitch:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [sender setTitle:sender.selected ? @"style2" : @"style1" forState:UIControlStateNormal];
    
    if (self.editTarget == currentTargetBase) {
        [[GPURenderEngine renderEngine] updateBaseFilterStyleWithFilterStyle:FilterLineCityStyleType];
    } else if (self.editTarget == currentTargetFill) {
        [[GPURenderEngine renderEngine] updateBaseFilterStyleWithFilterStyle:FilterLineCartoonStyleType];
    }
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

- (void)colorMask:(UIButton *)sender
{
    
}

- (void)colorOffset:(UISlider *)slider
{
    
}

- (void)timeLineOffset:(UISlider *)sender
{
    AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"fillV" ofType:@".mp4"]]];
    
    CGFloat duration = CMTimeGetSeconds(videoAsset.duration);
    
    
    CGFloat second = sender.value * duration;
    int preferredTimeScale = 1 * NSEC_PER_SEC;
    CMTime currentTime = CMTimeMakeWithSeconds(second, preferredTimeScale);
//    [self.player seekToTime:currentTime];
//    CGFloat speed = self.speed * 2.0;
//    if (speed == -4) {
//        speed = 0.25;
//    } else if (speed == -2)
//    {
//        speed = 0.5;
//    } else if (speed == 0)
//    {
//        speed = 1;
//    } else if (speed == 2)
//    {
//        speed = 2;
//    } else if (speed == 4)
//    {
//        speed = 4;
//    }
//    self.player.rate = speed;
    [[GPURenderEngine renderEngine] seekToTime:currentTime];
}

- (void)hiddenFill:(UIButton *)sender
{
    NSLog(@"隐藏遮罩和填充");
    sender.selected = !sender.selected;
    [[GPURenderEngine renderEngine] setMaskAndFillHidden:sender.selected];
    
}

- (void)speedBtn:(UIButton *)sender
{
    self.speed++;
    if (self.speed > 2) {
        self.speed = -2;
    }
    
    CGFloat speed = self.speed * 2.0;
    [sender setTitle:[NSString stringWithFormat:@"speed%ld", (long)speed] forState:UIControlStateNormal];
    if (speed == -4) {
        speed = 0.25;
        [[GPURenderEngine renderEngine] setFillVideoSpeed:GPUVideo4SpeedDecelerateType];
    } else if (speed == -2)
    {
        speed = 0.5;
        [[GPURenderEngine renderEngine] setFillVideoSpeed:GPUVideo2SpeedDecelerateType];
    } else if (speed == 0)
    {
        speed = 1;
        [[GPURenderEngine renderEngine] setFillVideoSpeed:GPUVideoSpeedNormalType];
    } else if (speed == 2)
    {
        speed = 2;
        [[GPURenderEngine renderEngine] setFillVideoSpeed:GPUVideo2SpeedAccelerateType];

    } else if (speed == 4)
    {
        speed = 4;
        [[GPURenderEngine renderEngine] setFillVideoSpeed:GPUVideo4SpeedAccelerateType];
    }
    
    
    NSLog(@"speed%f",speed);
    
//    self.player.rate = speed;
    
}

- (void)switchTarget:(UIButton *)sender
{
    self.editTarget++;
    if (self.editTarget > 2) {
        self.editTarget = 0;
    }
    switch (self.editTarget) {
        case currentTargetBase:
            [sender setTitle:@"Base" forState:UIControlStateNormal];
            break;
        case currentTargetFill:
            [sender setTitle:@"Fill" forState:UIControlStateNormal];
            break;
        case currentTargetText:
            [sender setTitle:@"Mask" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }

}

- (void)engine {
    
    AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"fillV" ofType:@".mp4"]]];
    
    CGFloat duration = CMTimeGetSeconds(videoAsset.duration);
    
    GPURenderEngine *renderEngine = [GPURenderEngine renderEngine];
    [renderEngine setRenderView:gView];
    render_color maskColor = {
        0.1,
        0.1,
        0.1,
        0.1
    };
    pic = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"fill"]];
    //baseColorSelectMask
    [renderEngine updateColorMaskColorAndTolerance:maskColor];
    //base
    [renderEngine updateBaseResourceWithImage:[UIImage imageNamed:@"fill"]];
    [renderEngine updateBaseFilterStyleWithFilterStyle:FilterLineCartoonStyleType];
    //fill
    [renderEngine updateFillResourceWithVideoAsset:videoAsset];
    [renderEngine updateFillFilterStyleWithFilterStyle:FilterLineCityStyleType];
    [renderEngine setFillVideoStartTime:kCMTimeZero];
    [renderEngine setFillVideoEndTime:videoAsset.duration];

    //textMask
    [renderEngine updateTextMaskWithTextImage:[UIImage imageNamed:@"b10"]];
    
    //eraserMask
    [renderEngine updateEraserMaskWithEraserRawData:self.eraseData];
}

- (void)setupFilters {
    
    [self engine];

    [self test];
}

- (void)test
{
    
    self.textTrans = [[GPUImageTransformFilter alloc] init];
    //    pic = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"base"]];
    //
    self.baseTrans = [[GPUImageTransformFilter alloc] init];
    //    self.baseTrans.transform3D = [self setContentModeAspectToFitWithSize:pic.outputImageSize];
    //
    //    self.blendFilter = [[NUMAMultiplyBlendFilter alloc] init];
    //
    //    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"baseV" ofType:@".mp4"]];
    //
    //    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    //    self.player = [[AVPlayer alloc] initWithPlayerItem:item];
    //    _player.rate = 1.0;
    //    _player.volume = 0;
    //
    //    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
    //        NSLog(@"dssd");
    //    }
    //    __weak typeof(self) weakSelf = self;
    //    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
    //
    //        CGFloat duration = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
    //        CGFloat current = CMTimeGetSeconds(weakSelf.player.currentItem.currentTime);
    //
    //        weakSelf.videoTimeLine.value = current / duration;
    //
    //        if (CMTimeGetSeconds(weakSelf.player.currentItem.currentTime) == CMTimeGetSeconds(weakSelf.player.currentItem.duration)) {
    //            [weakSelf.player pause];
    //            [weakSelf.player seekToTime:kCMTimeZero];
    //            CGFloat speed = self.speed * 2.0;
    //            if (speed == -4) {
    //                speed = 0.25;
    //            } else if (speed == -2)
    //            {
    //                speed = 0.5;
    //            } else if (speed == 0)
    //            {
    //                speed = 1;
    //            } else if (speed == 2)
    //            {
    //                speed = 2;
    //            } else if (speed == 4)
    //            {
    //                speed = 4;
    //            }
    //            [weakSelf.player play];
    //            weakSelf.player.rate = speed;
    //        }
    //
    //    }];
    //
    //    GPUImageMovie *movie = [[GPUImageMovie alloc] initWithPlayerItem:item];
    //    movie.runBenchmark = YES;
    //    movie.playAtActualSpeed = YES;
    //
    //
    self.FillTrans = [[GPUImageTransformFilter alloc] init];
    //    self.FillTrans.transform3D = [self setContentModeAspectToFitWithSize:pic.outputImageSize];
    //
    //    [pic addTarget:self.baseTrans];
    //    [movie addTarget:self.FillTrans];
    //    [self.baseTrans addTarget:self.blendFilter atTextureLocation:0];
    //    [self.FillTrans addTarget:self.blendFilter atTextureLocation:1];
    //
    //    [pic processImage];
    //
    //    [self.blendFilter addTarget:gView];
    //
    //    [movie startProcessing];
    //    movie.renderFrameBlock = ^{
    //        [pic processImage];
    //    };
    //
    //    [self.player play];
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
                [[GPURenderEngine renderEngine] updateBaseWithTransform:transform];
            }
            break;
        case currentTargetFill:
        {
            CATransform3D transform = self.FillTrans.transform3D;
            transform.m41 = transform.m41 + (point.x - self.lastPoint.x)/self.view.frame.size.width*2;
            transform.m42 = transform.m42 + (point.y- self.lastPoint.y)/self.view.frame.size.width*2;
            self.FillTrans.transform3D = transform;
            [[GPURenderEngine renderEngine] updateFillWithTransform:transform];
        }
            break;
        case currentTargetText:
            {
                CATransform3D transform = self.textTrans.transform3D;
                transform.m41 = transform.m41 + (point.x - self.lastPoint.x)/self.view.frame.size.width*2;
                transform.m42 = transform.m42 + (point.y - self.lastPoint.y)/self.view.frame.size.width*2;
                self.textTrans.transform3D = transform;
                [[GPURenderEngine renderEngine] updateTextMaskWithTransform:transform];
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
            [[GPURenderEngine renderEngine] updateBaseWithTransform:CATransform3DScale(self.baseTrans.transform3D, sender.scale, sender.scale, 1)];

            break;
        case currentTargetFill:
            self.FillTrans.transform3D = CATransform3DScale(self.FillTrans.transform3D, sender.scale, sender.scale, 1);
            [[GPURenderEngine renderEngine] updateFillWithTransform:CATransform3DScale(self.FillTrans.transform3D, sender.scale, sender.scale, 1)];

            break;
        case currentTargetText:
            self.textTrans.transform3D = CATransform3DScale(self.textTrans.transform3D, sender.scale, sender.scale, 1);
            [[GPURenderEngine renderEngine] updateTextMaskWithTransform:CATransform3DScale(self.textTrans.transform3D, sender.scale, sender.scale, 1)];

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
            [[GPURenderEngine renderEngine] updateBaseWithTransform:CATransform3DRotate(self.baseTrans.transform3D, sender.rotation, 0, 0, 1)];

            break;
        case currentTargetFill:
            self.FillTrans.transform3D = CATransform3DRotate(self.FillTrans.transform3D, sender.rotation, 0, 0, 1);
            [[GPURenderEngine renderEngine] updateFillWithTransform:CATransform3DRotate(self.FillTrans.transform3D, sender.rotation, 0, 0, 1)];

            break;
        case currentTargetText:
            self.textTrans.transform3D = CATransform3DRotate(self.textTrans.transform3D, sender.rotation, 0, 0, 1);
            [[GPURenderEngine renderEngine] updateTextMaskWithTransform:CATransform3DRotate(self.textTrans.transform3D, sender.rotation, 0, 0, 1)];

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




- (void)resetEraseData {
    
    if (self.eraseData != NULL) {
        free(self.eraseData);
        self.eraseData = NULL;
    }
    
    const size_t bitsPerComponent = 8;
    const size_t bytesPerRow = panelSize.width * 4; //1byte per pixel
    self.eraseData = calloc(sizeof(unsigned char), bytesPerRow * panelSize.height);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef context =
    CGBitmapContextCreate(self.eraseData, panelSize.width, panelSize.height,
                          bitsPerComponent, bytesPerRow,
                          colorSpaceRef,
                          kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpaceRef);
    if(NULL == context) {
        NSLog(@"resetEraseData: Could not create the context");
        CGContextRelease(context);
        return;
    }
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.0] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, panelSize.width, panelSize.height));
    CGContextTranslateCTM(context, 0, panelSize.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);

    CGImageRef cgImg = CGBitmapContextCreateImage(context);
    UIImage *img = [UIImage imageWithCGImage:cgImg];
    
    CGContextRelease(context);
}

@end
