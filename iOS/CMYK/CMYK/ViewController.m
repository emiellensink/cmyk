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
#import "Implementation/CMYKRotationAnimator.h"
#import "Implementation/CMYKWaveAnimator.h"

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
	self.preferredFramesPerSecond = 60;
    
	self.engine = [QX3DEngine engineWithScene:[CMYKScene new]];
	
    [self setupGL];
	
	CMYKScene *scene = (CMYKScene *)self.engine.scene;
		
	QX3DMaterial *mat = [QX3DMaterial materialWithVertexProgram:@"subtractive" pixelProgram:@"subtractive" attributes:@{@"position": @(GLKVertexAttribPosition)}];
	
	for (int x = 0; x < 3; x++)
	{
	for (int i = 0; i < 20; i++)
	{
		QX3DObject *obj = [QX3DObject new];
		obj.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
		obj.position = GLKVector3Make(0, -1.0 + (i * (2.0 / 20.0)), 0);
		
		[obj attachToObject:scene];
		
		CMYKWaveAnimator *wave = [CMYKWaveAnimator animatorForObject:obj];
		wave.speed = 2.2;
		wave.amplitude = 1;
		wave.offset = (x / 2.0) + (i / 10.0);
		
		CMYKRotationAnimator *anim = [CMYKRotationAnimator animatorForObject:obj];
		anim.speed = 1;
		
		CMYKRenderableSquare *square = [CMYKRenderableSquare renderableForObject:obj];
		if (x == 0) square.color = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1];
		if (x == 1) square.color = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
		if (x == 2) square.color = [UIColor colorWithRed:0 green:0 blue:0.5 alpha:1];
		
		[square warmup];

		square.material = mat;
	}
	}
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
