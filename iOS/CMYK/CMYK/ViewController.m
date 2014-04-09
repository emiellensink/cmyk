//
//  ViewController.m
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "ViewController.h"

#import "QX3D/QX3DEngine.h"
#import "QX3D/QX3DObject.h"
#import "QX3D/QX3DMaterial.h"

#import "Implementation/CMYKScene.h"
#import "Implementation/CMYKRenderableSquare.h"

@interface ViewController () {

}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) QX3DEngine *engine;

- (void)setupGL;
- (void)tearDownGL;

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
	
	CMYKScene *scene = (CMYKScene *)self.engine.scene;
	
	QX3DObject *obj = [QX3DObject new];
	obj.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
	
	[obj attachToObject:scene];
	
	CMYKRenderableSquare *square = [CMYKRenderableSquare renderableForObject:obj];
	[square warmup];
	QX3DMaterial *mat = [QX3DMaterial materialWithVertexProgram:@"subtractive" pixelProgram:@"subtractive" attributes:@{@"position": @(GLKVertexAttribPosition)}];
	square.material = mat;
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

@end
