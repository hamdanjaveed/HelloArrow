//
//  GLView.m
//  HelloArrow
//
//  Created by Hamdan Javeed on 2013-06-27.
//  Copyright (c) 2013 Hamdan Javeed. All rights reserved.
//

#import "GLView.h"
#import "RenderingEngineES1.h"
#import "RenderingEngineES2.h"
#import <OpenGLES/EAGL.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>

@interface GLView()
@property (nonatomic) EAGLContext *context;
@property (nonatomic) id <RenderingEngine> renderingEngine;
@property (nonatomic) float timeStamp;
@property (nonatomic) bool forceES1;

- (void)render:(CADisplayLink *)displayLink;
- (void)didRotate:(NSNotification *)notification;
@end

@implementation GLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (EAGLContext *)context {
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!_context || self.forceES1) {
            _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        }
    }
    return _context;
}

- (id)renderingEngine {
    if (!_renderingEngine) {
        if ([self.context API] == kEAGLRenderingAPIOpenGLES2) {
            NSLog(@"Using OpenGL ES 2.0");
            _renderingEngine = [[RenderingEngineES2 alloc] init];
        } else {
            NSLog(@"Using OpenGL ES 1.1");
            _renderingEngine = [[RenderingEngineES1 alloc] init];
        }
    }
    return _renderingEngine;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CAEAGLLayer *myLayer = (CAEAGLLayer *)super.layer;
        [myLayer setOpaque:YES];
        
        if (!self.context || ![EAGLContext setCurrentContext:self.context]) {
            return nil;
        }
        
        [self.renderingEngine create];
        
        [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:myLayer];
        
        [self.renderingEngine initializeStateWithFrame:frame];
        
        [self render:nil];
        
        self.timeStamp = CACurrentMediaTime();
        
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self
                                                                 selector:@selector(render:)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSDefaultRunLoopMode];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)render:(CADisplayLink *)displayLink {
    if (displayLink != nil) {
        float elapsedSeconds = displayLink.timestamp - self.timeStamp;
        self.timeStamp = displayLink.timestamp;
        [self.renderingEngine updateAnimationWithTimeStep:elapsedSeconds];
    }
    [self.renderingEngine render];
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)didRotate:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    [self.renderingEngine deviceDidRotateToOrientation:orientation];
    [self render:nil];
}

- (void)dealloc {
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

@end
