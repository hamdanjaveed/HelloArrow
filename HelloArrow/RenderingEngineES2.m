//
//  RenderingEngineES2.m
//  HelloArrow
//
//  Created by Hamdan Javeed on 2013-06-27.
//  Copyright (c) 2013 Hamdan Javeed. All rights reserved.
//

#import "RenderingEngineES2.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef struct {
    float position[2];
    float color[4];
} vertex;

const vertex vertices2[] = {
    {{-0.5f, -0.866f}, {0.8f, 0.4f, 0.2f, 1.0f}},
    {{ 0.5f, -0.866f}, {0.8f, 0.4f, 0.2f, 1.0f}},
    {{ 0.0f,    1.0f}, {0.8f, 0.4f, 0.2f, 1.0f}},
    
    {{-0.5f, -0.866f}, {0.5f, 0.5f, 0.5f, 1.0f}},
    {{ 0.5f, -0.866f}, {0.5f, 0.5f, 0.5f, 1.0f}},
    {{ 0.0f,   -0.4f}, {0.5f, 0.5f, 0.5f, 1.0f}},
};

@interface RenderingEngineES2() {
    GLuint frameBuffer;
    GLuint renderBuffer;
    GLuint simpleProgram;
}

@property (nonatomic) GLfloat currentDegrees;
@property (nonatomic, readonly) GLfloat revolutionsPerSecond;
@property (nonatomic) GLfloat desiredAngle;
@property (nonatomic) NSString *simpleVertexShader;
@property (nonatomic) NSString *simpleFragmentShader;

- (float)rotationDirection;
- (GLuint)buildShaderWithSource:(const char*)source andShaderType:(GLenum)shaderType;
- (GLuint)buildProgramWithVertexShader:(const char*)vertexShader andFragmentShader:(const char*)fragmentShader;
- (void)applyOrthoWithMaxX:(float)maxX andMaxY:(float)maxY;
- (void)applyRotationOf:(float)degrees;
@end

@implementation RenderingEngineES2

- (GLfloat)revolutionsPerSecond {
    return 1.0f;
}

- (NSString *)simpleVertexShader {
    if (!_simpleVertexShader) {
        _simpleVertexShader = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Vertex" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    }
    return _simpleVertexShader;
}

- (NSString *)simpleFragmentShader {
    if (!_simpleFragmentShader) {
        _simpleFragmentShader = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Fragment" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    }
    return _simpleFragmentShader;
}

- (void)create {
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
}

- (void)initializeStateWithFrame:(CGRect)frame {
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    
    glViewport(0, 0, frame.size.width, frame.size.height);
    
    simpleProgram = [self buildProgramWithVertexShader:[self.simpleVertexShader UTF8String] andFragmentShader:[self.simpleFragmentShader UTF8String]];
    
    glUseProgram(simpleProgram);
    
    [self applyOrthoWithMaxX:2.0f andMaxY:3.0f];
    [self deviceDidRotateToOrientation:UIDeviceOrientationPortrait];
    
    self.currentDegrees = self.desiredAngle;
}

- (void)render {
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self applyRotationOf:self.currentDegrees];
    
    GLuint positionSlot = glGetAttribLocation(simpleProgram, "position");
    GLuint colorSlot = glGetAttribLocation(simpleProgram, "sourceColor");
    
    glEnableVertexAttribArray(positionSlot);
    glEnableVertexAttribArray(colorSlot);
    
    glVertexAttribPointer(positionSlot, 2, GL_FLOAT, GL_FALSE, sizeof(vertex), &vertices2[0].position[0]);
    glVertexAttribPointer(colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(vertex), &vertices2[0].color[0]);
    
    glDrawArrays(GL_TRIANGLES, 0, sizeof(vertices2) / sizeof(vertices2[0]));

    glDisableVertexAttribArray(positionSlot);
    glDisableVertexAttribArray(colorSlot);
}

- (void)updateAnimationWithTimeStep:(float)timeStep {
    float direction = [self rotationDirection];
    if (direction != 0) {
        float degrees = timeStep * 360 * self.revolutionsPerSecond;
        self.currentDegrees += degrees * direction;
        
        if (self.currentDegrees >= 360) {
            self.currentDegrees -= 360;
        } else if (self.currentDegrees < 0) {
            self.currentDegrees += 360;
        }
        
        if ([self rotationDirection] != direction) {
            self.currentDegrees = self.desiredAngle;
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
    float delta = self.desiredAngle - self.currentDegrees;
    if (delta == 0) {
        return 0;
    }
    bool counterClockWise = ((delta > 0 && delta <= 180) || delta < -180);
    return counterClockWise ? 1.0f : -1.0f;
}

- (GLuint)buildShaderWithSource:(const char*)source andShaderType:(GLenum)shaderType {
    GLuint shaderHandle = glCreateShader(shaderType);
    glShaderSource(shaderHandle, 1, &source, 0);
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSLog(@"COULD NOT COMPILE SHADER");
        NSLog(@"%s", messages);
        exit(1);
    }
    
    return shaderHandle;
}

- (GLuint)buildProgramWithVertexShader:(const char*)vertexShaderSource andFragmentShader:(const char*)fragmentShaderSource {
    GLuint vertexShader = [self buildShaderWithSource:vertexShaderSource andShaderType:GL_VERTEX_SHADER];
    GLuint fragShader = [self buildShaderWithSource:fragmentShaderSource andShaderType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSLog(@"COULD NOT COMPILE PROGRAM");
        NSLog(@"%s", messages);
        exit(1);
    }
    
    return programHandle;
}

- (void)applyOrthoWithMaxX:(float)maxX andMaxY:(float)maxY {
    float a = 1.0f / maxX;
    float b = 1.0f / maxY;
    float ortho[16] = {
        a, 0, 0, 0,
        0, b, 0, 0,
        0, 0, -1, 0,
        0, 0, 0, 1
    };
    
    GLint projectionUniform = glGetUniformLocation(simpleProgram, "projection");
    glUniformMatrix4fv(projectionUniform, 1, 0, &ortho[0]);
}

- (void)applyRotationOf:(float)degrees {
    float radians = degrees * M_PI / 180.0f;
    float s = sinf(radians);
    float c = cosf(radians);
    float zRotation[16] = {
        c, s, 0, 0,
        -s, c, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    };
    
    GLint modelViewUniform = glGetUniformLocation(simpleProgram, "modelView");
    glUniformMatrix4fv(modelViewUniform, 1, 0, &zRotation[0]);
}

@end
