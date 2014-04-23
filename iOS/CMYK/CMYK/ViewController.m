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

@interface ViewController ()
{
	BOOL trackFromButton;
	NSUInteger trackButtonIndex;
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

#pragma mark Prototype UI and gameplay

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *buttons = @[self.b1, self.b2, self.b3, self.b4];
	
	CGPoint loc = [[touches anyObject] locationInView:self.view];

	[buttons enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop)
	{
		if (CGRectContainsPoint(obj.frame, loc))
		{
			trackFromButton = YES;
			trackButtonIndex = idx;
		}
	}];
	
	CMYKScene *scene = (CMYKScene *)self.engine.scene;
	if (trackFromButton)[scene beginTrackingFromButton:trackButtonIndex withFrameSize:self.view.frame.size position:loc];
	else
		[scene beginTrackingWithFrameSize:self.view.frame.size position:loc];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint loc = [[touches anyObject] locationInView:self.view];

	CMYKScene *scene = (CMYKScene *)self.engine.scene;
	[scene moveTrackingWithFrameSize:self.view.frame.size position:loc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint loc = [[touches anyObject] locationInView:self.view];
	
	CMYKScene *scene = (CMYKScene *)self.engine.scene;
	[scene endTrackingWithFrameSize:self.view.frame.size position:loc];
	
	trackFromButton = NO;
	trackButtonIndex = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	CMYKScene *scene = (CMYKScene *)self.engine.scene;
	[scene cancelTracking];
	
	trackFromButton = NO;
	trackButtonIndex = 0;
}

@end
