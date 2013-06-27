//
//  GLView.m
//  HelloArrow
//
//  Created by Hamdan Javeed on 2013-06-27.
//  Copyright (c) 2013 Hamdan Javeed. All rights reserved.
//

#import "GLView.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>

@interface GLView()
@property (nonatomic) EAGLContext *context;

- (void)render;
@end

@implementation GLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (EAGLContext *)context {
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    }
    return _context;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CAEAGLLayer *myLayer = (CAEAGLLayer *)super.layer;
        [myLayer setOpaque:YES];
        
        if (!self.context || ![EAGLContext setCurrentContext:self.context]) {
            return nil;
        }
        
        GLuint framebuffer, renderbuffer;
        glGenFramebuffers(1, &framebuffer);
        glGenRenderbuffers(1, &renderbuffer);
        
        glBindFramebuffer(GL_FRAMEBUFFER_OES, framebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER_OES, renderbuffer);
        
        [self.context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:myLayer];
        
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, renderbuffer);
        
        glViewport(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        
        [self render];
    }
    return self;
}

- (void)render {
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void)dealloc {
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

@end
