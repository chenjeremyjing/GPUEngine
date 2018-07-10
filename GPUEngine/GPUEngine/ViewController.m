//
//  ViewController.m
//  GPUEngine
//
//  Created by Jeremy Liu on 18/6/28.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"

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
    
}

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) GPUImageAlphaBlendFilter *blendFilter;

@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic, strong) GPUImageTransformFilter *baseTrans;
@property (nonatomic, strong) GPUImageTransformFilter *FillTrans;
@property (nonatomic, strong) GPUImageTransformFilter *textTrans;

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, assign) currentTarget editTarget;


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
    
    
}

- (void)hiddenFill:(UIButton *)sender
{
    
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
            [sender setTitle:@"Text" forState:UIControlStateNormal];
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
