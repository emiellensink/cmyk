//
//  ViewController.m
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "ViewController.h"

#import "QX3D/QX3DEngine.h"
#import "Implementation/CMYKScene.h"

@interface ViewController () {

}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) QX3DEngine *engine;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context)
	{
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
	self.engine = [QX3DEngine engineWithScene:[CMYKScene new]];
	
    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context)
        [EAGLContext setCurrentContext:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil))
	{
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
	
	[self.engine setupGL];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];

	[self.engine cleanupGL];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
	[self.engine updateWithView:self.view interval:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	[self.engine renderInView:self.view rect:rect];
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
	return NO;
	
//    GLuint vertShader, fragShader;
//    NSString *vertShaderPathname, *fragShaderPathname;
//    
//    // Create shader program.
//    _program = glCreateProgram();
//    
//    // Create and compile vertex shader.
//    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
//    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
//        NSLog(@"Failed to compile vertex shader");
//        return NO;
//    }
//    
//    // Create and compile fragment shader.
//    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
//    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
//        NSLog(@"Failed to compile fragment shader");
//        return NO;
//    }
//    
//    // Attach vertex shader to program.
//    glAttachShader(_program, vertShader);
//    
//    // Attach fragment shader to program.
//    glAttachShader(_program, fragShader);
//    
//    // Bind attribute locations.
//    // This needs to be done prior to linking.
//    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
//    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
//    
//    // Link program.
//    if (![self linkProgram:_program]) {
//        NSLog(@"Failed to link program: %d", _program);
//        
//        if (vertShader) {
//            glDeleteShader(vertShader);
//            vertShader = 0;
//        }
//        if (fragShader) {
//            glDeleteShader(fragShader);
//            fragShader = 0;
//        }
//        if (_program) {
//            glDeleteProgram(_program);
//            _program = 0;
//        }
//        
//        return NO;
//    }
//    
//    // Get uniform locations.
//    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
//    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
//    
//    // Release vertex and fragment shaders.
//    if (vertShader) {
//        glDetachShader(_program, vertShader);
//        glDeleteShader(vertShader);
//    }
//    if (fragShader) {
//        glDetachShader(_program, fragShader);
//        glDeleteShader(fragShader);
//    }
//    
//    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
	return NO;
	
	//    GLint status;
//    const GLchar *source;
//    
//    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
//    if (!source) {
//        NSLog(@"Failed to load vertex shader");
//        return NO;
//    }
//    
//    *shader = glCreateShader(type);
//    glShaderSource(*shader, 1, &source, NULL);
//    glCompileShader(*shader);
//    
//#if defined(DEBUG)
//    GLint logLength;
//    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
//    if (logLength > 0) {
//        GLchar *log = (GLchar *)malloc(logLength);
//        glGetShaderInfoLog(*shader, logLength, &logLength, log);
//        NSLog(@"Shader compile log:\n%s", log);
//        free(log);
//    }
//#endif
//    
//    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
//    if (status == 0) {
//        glDeleteShader(*shader);
//        return NO;
//    }
//    
//    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
	return NO;
	
//    GLint status;
//    glLinkProgram(prog);
//    
//#if defined(DEBUG)
//    GLint logLength;
//    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
//    if (logLength > 0) {
//        GLchar *log = (GLchar *)malloc(logLength);
//        glGetProgramInfoLog(prog, logLength, &logLength, log);
//        NSLog(@"Program link log:\n%s", log);
//        free(log);
//    }
//#endif
//    
//    glGetProgramiv(prog, GL_LINK_STATUS, &status);
//    if (status == 0) {
//        return NO;
//    }
//    
//    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
	return NO;
//    GLint logLength, status;
//    
//    glValidateProgram(prog);
//    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
//    if (logLength > 0) {
//        GLchar *log = (GLchar *)malloc(logLength);
//        glGetProgramInfoLog(prog, logLength, &logLength, log);
//        NSLog(@"Program validate log:\n%s", log);
//        free(log);
//    }
//    
//    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
//    if (status == 0) {
//        return NO;
//    }
//    
//    return YES;
}

@end
