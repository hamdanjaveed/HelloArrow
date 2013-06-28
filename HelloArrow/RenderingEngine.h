//
//  RenderingEngine.h
//  HelloArrow
//
//  Created by Hamdan Javeed on 2013-06-27.
//  Copyright (c) 2013 Hamdan Javeed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


@protocol RenderingEngine <NSObject>
- (void)create;
- (void)initializeStateWithFrame:(CGRect)frame;
- (void)render;
- (void)updateAnimationWithTimeStep:(float)timeStep;
- (void)deviceDidRotateToOrientation:(UIDeviceOrientation)orientation;
@end
