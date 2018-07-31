//
//  NUMARenderView.h
//  GPUEngine
//
//  Created by BeautyHZ on 2018/7/31.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import "GPUImageView.h"

typedef void(^TransformActionBlock)(CATransform3D transform, currentTarget targetType);
typedef void(^EraserActionBlock)(CGPoint currentLocation, CGPoint preLocation);

@interface NUMARenderView : GPUImageView

@property (nonatomic, assign) currentTarget editTarget;

@property (nonatomic, assign) CATransform3D baseInitialTrans;
@property (nonatomic, assign) CATransform3D fillInitialTrans;
@property (nonatomic, assign) CATransform3D textMaskInitialTrans;

- (void)renderWithTransformHandler:(TransformActionBlock)transformHandler;

- (void)eraserActionWithHandler:(EraserActionBlock)eraserActionHandler;

@end
