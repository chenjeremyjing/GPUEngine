//
//  NUMARenderView.m
//  GPUEngine
//
//  Created by BeautyHZ on 2018/7/31.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "NUMARenderView.h"

@interface NUMARenderView()

@property (nonatomic, copy) TransformActionBlock transformBlock;
@property (nonatomic, copy) EraserActionBlock eraserBlock;
@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic, assign) CATransform3D baseTrans;
@property (nonatomic, assign) CATransform3D fillTrans;
@property (nonatomic, assign) CATransform3D textMaskTrans;

@end

@implementation NUMARenderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        self.fillMode = kGPUImageFillModeStretch;
        self.opaque = YES;
        self.layer.opaque = YES;
        self.layer.masksToBounds = YES;
        [self setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:0.0];
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:panGes];
        
        UIPinchGestureRecognizer *pinchGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGes:)];
        [self addGestureRecognizer:pinchGes];
        
        UIRotationGestureRecognizer *rotateGes = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGes:)];
        [self addGestureRecognizer:rotateGes];
        
        self.baseTrans = CATransform3DIdentity;
        self.fillTrans = CATransform3DIdentity;
        self.textMaskTrans = CATransform3DIdentity;

    }
    return self;
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
            CATransform3D transform = self.baseTrans;
            transform.m41 = transform.m41 + (point.x - self.lastPoint.x)/panelSize.width*2;
            transform.m42 = transform.m42 + (point.y - self.lastPoint.y)/panelSize.width*2;
            self.baseTrans = transform;
            [self setCurrentTransform:transform];
        }
            break;
        case currentTargetFill:
        {
            CATransform3D transform = self.fillTrans;
            transform.m41 = transform.m41 + (point.x - self.lastPoint.x)/panelSize.width;
            transform.m42 = transform.m42 + (point.y- self.lastPoint.y)/panelSize.width;
            self.fillTrans = transform;
            [self setCurrentTransform:transform];
        }
            break;
        case currentTargetText:
        {
            CATransform3D transform = self.textMaskTrans;
            transform.m41 = transform.m41 + (point.x - self.lastPoint.x)/panelSize.width*2;
            transform.m42 = transform.m42 + (point.y - self.lastPoint.y)/panelSize.width*2;
            self.textMaskTrans = transform;
            [self setCurrentTransform:transform];
        }
            break;
        case currentTargetEraser:
        {
            if (self.eraserBlock) {
                self.eraserBlock(point, self.lastPoint);
            }
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
            self.baseTrans = CATransform3DScale(self.baseTrans, sender.scale, sender.scale, 1);
            [self setCurrentTransform:CATransform3DScale(self.baseTrans, sender.scale, sender.scale, 1)];

            break;
        case currentTargetFill:
            self.fillTrans = CATransform3DScale(self.fillTrans, sender.scale, sender.scale, 1);
            [self setCurrentTransform:CATransform3DScale(self.fillTrans, sender.scale, sender.scale, 1)];

            break;
        case currentTargetText:
            self.textMaskTrans = CATransform3DScale(self.textMaskTrans, sender.scale, sender.scale, 1);
            [self setCurrentTransform:CATransform3DScale(self.textMaskTrans, sender.scale, sender.scale, 1)];

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
            self.baseTrans = CATransform3DRotate(self.baseTrans, sender.rotation, 0, 0, 1);
            [self setCurrentTransform:CATransform3DRotate(self.baseTrans, sender.rotation, 0, 0, 1)];

            break;
        case currentTargetFill:
            self.fillTrans = CATransform3DRotate(self.fillTrans, sender.rotation, 0, 0, 1);
            [self setCurrentTransform:CATransform3DRotate(self.fillTrans, sender.rotation, 0, 0, 1)];

            break;
        case currentTargetText:
            self.textMaskTrans = CATransform3DRotate(self.textMaskTrans, sender.rotation, 0, 0, 1);
            [self setCurrentTransform:CATransform3DRotate(self.textMaskTrans, sender.rotation, 0, 0, 1)];

            break;
            
        default:
            break;
    }
    sender.rotation = 0.0f;
}

- (void)updateTextMaskTransformWithRotation:(CGFloat)rotation x:(CGFloat)x y:(CGFloat)y z:(CGFloat)z
{
    self.textMaskTrans = CATransform3DRotate(self.textMaskTrans, rotation, x, y, z);
    self.editTarget = currentTargetText;
    [self setCurrentTransform:self.textMaskTrans];
}

- (void)resetTransform
{
    
    
    switch (self.editTarget) {
        case currentTargetBase:
        {
            self.baseTrans = CATransform3DIdentity;
        }
            break;
        case currentTargetFill:
        {
            self.fillTrans = CATransform3DIdentity;
        }
            break;
        case currentTargetText:
        {
            self.textMaskTrans = CATransform3DIdentity;

        }
            break;
            
        default:
            break;
    }
}

- (void)setCurrentTransform:(CATransform3D)transform
{
    if (self.transformBlock) {
        self.transformBlock(transform, self.editTarget);
    }
}

- (void)renderWithTransformHandler:(TransformActionBlock)transformHandler
{
    self.transformBlock = transformHandler;
}

- (void)eraserActionWithHandler:(EraserActionBlock)eraserActionHandler
{
    self.eraserBlock = eraserActionHandler;
}

@end
