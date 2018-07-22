//
//  ColorCompensationFilter.h
//  GPUEngine
//
//  Created by Jeremy Liu on 18/7/1.
//  Copyright © 2018年 com.Jeremy. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface ColorCompensationFilter : GPUImageFilter
{
    GLint colorR_Uniform;
    GLint colorG_Uniform;
    GLint colorB_Uniform;
    GLint colorAlpha_Uniform;
    
}

@property(assign, nonatomic) CGFloat r;
@property(assign, nonatomic) CGFloat g;
@property(assign, nonatomic) CGFloat b;
@property(assign, nonatomic) CGFloat a;

@end
