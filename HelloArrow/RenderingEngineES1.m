//
//  RenderingEngineES1.m
//  HelloArrow
//
//  Created by Hamdan Javeed on 2013-06-27.
//  Copyright (c) 2013 Hamdan Javeed. All rights reserved.
//

#import "RenderingEngineES1.h"

typedef struct {
    float position[2];
    float color[4];
} vertex;

const vertex vertices[] = {
    {{-0.5f, -0.866f}, {0.8f, 0.4f, 0.2f, 1.0f}},
    {{ 0.5f, -0.866f}, {0.8f, 0.4f, 0.2f, 1.0f}},
    {{ 0.0f,    1.0f}, {0.8f, 0.4f, 0.2f, 1.0f}},
    
    {{-0.5f, -0.866f}, {0.5f, 0.5f, 0.5f, 1.0f}},
    {{ 0.5f, -0.866f}, {0.5f, 0.5f, 0.5f, 1.0f}},
    {{ 0.0f,   -0.4f}, {0.5f, 0.5f, 0.5f, 1.0f}},
};

@interface RenderingEngineES1() {
    GLuint frameBuffer;
    GLuint renderBuffer;
}

@property (nonatomic) GLfloat deviceAngleInDegrees;
@property (nonatomic, readonly) GLfloat revolutionsPerSecond;
@property (nonatomic) GLfloat desiredAngle;

- (float)rotationDirection;
@end

@implementation RenderingEngineES1

- (GLfloat)revolutionsPerSecond {
    return 1.0f;
}

- (void)create {
    glGenRenderbuffersOES(1, &renderBuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderBuffer);
}

- (void)initializeStateWithFrame:(CGRect)frame {
    glGenFramebuffersOES(1, &frameBuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, renderBuffer);
    
    glViewport(0, 0, frame.size.width, frame.size.height);
    
    glMatrixMode(GL_PROJECTION);
    const float maxX = 2.0f;
    const float maxY = 3.0f;
    glOrthof(-maxX, maxX, -maxY, maxY, -1.0f, 1.0f);
    
    glMatrixMode(GL_MODELVIEW);
    
    [self deviceDidRotateToOrientation:UIDeviceOrientationPortrait];
    self.deviceAngleInDegrees = self.desiredAngle;
}

- (void)render {
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glPushMatrix(); {
        glRotatef(self.deviceAngleInDegrees, 0.0f, 0.0f, 1.0f);
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_COLOR_ARRAY);
    
        glVertexPointer(2, GL_FLOAT, sizeof(vertex), &vertices[0].position[0]);
        glColorPointer(4, GL_FLOAT, sizeof(vertex), &vertices[0].color[0]);
    
        glDrawArrays(GL_TRIANGLES, 0, sizeof(vertices) / sizeof(vertices[0]));
    
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_COLOR_ARRAY);
    } glPopMatrix();
}

- (void)updateAnimationWithTimeStep:(float)timeStep {
    float direction = [self rotationDirection];
    if (direction != 0) {
        float degrees = timeStep * 360 * self.revolutionsPerSecond;
        self.deviceAngleInDegrees += degrees * direction;
        
        if (self.deviceAngleInDegrees >= 360) {
            self.deviceAngleInDegrees -= 360;
        } else if (self.deviceAngleInDegrees < 0) {
            self.deviceAngleInDegrees += 360;
        }
        
        if ([self rotationDirection] != direction) {
            self.deviceAngleInDegrees = self.desiredAngle;
        }
    }
}

- (void)deviceDidRotateToOrientation:(UIDeviceOrientation)orientation {
    GLfloat angle = 0;
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            angle = 270;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            angle = 180;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            angle = 90;
            break;
            
        default:
            break;
    }
    self.desiredAngle = angle;
}

- (float)rotationDirection {
    float delta = self.desiredAngle - self.deviceAngleInDegrees;
    if (delta == 0) {
        return 0;
    }
    bool counterClockWise = ((delta > 0 && delta <= 180) || delta < -180);
    return counterClockWise ? 1.0f : -1.0f;
}

@end
