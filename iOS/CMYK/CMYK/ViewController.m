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

#import "Implementation/CMYKTileStack.h"
#import "Implementation/CMYKTetromino.h"

@interface ViewController () {

	CMYKTileStack *tiles[5][5];
	CMYKTetromino *tetromino;
	
	int px;
	int py;
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
		
	QX3DMaterial *flatmat = [QX3DMaterial materialWithVertexProgram:@"subtractive" pixelProgram:@"flatcolor" attributes:@{@"position": @(GLKVertexAttribPosition)}];

	QX3DMaterial *colormat = [QX3DMaterial materialWithVertexProgram:@"subtractive" pixelProgram:@"subtractive" attributes:@{@"position": @(GLKVertexAttribPosition)}];

	for (int x = -2; x <= 2; x++)
	{
		for (int y = -2; y <= 2; y++)
		{
			QX3DObject *obj = [QX3DObject new];
			obj.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
			obj.position = GLKVector3Make(x * 1.1, -y * 1.1, 0);

			CMYKRenderableSquare *square = [CMYKRenderableSquare renderableForObject:obj];
			square.color = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
			
			[square warmup];
			
			square.material = flatmat;
			[obj attachToObject:scene];
		
			CMYKTileStack *stack = [[CMYKTileStack alloc] initWithMaterial:colormat];
			stack.position = GLKVector3Make(x * 1.1, -y * 1.1, 0);

			[stack attachToObject:scene];
			
			tiles[x + 2][y + 2] = stack;
		}
	}
	
	tetromino = [[CMYKTetromino alloc] initWithMaterial:colormat];
	tetromino.position = GLKVector3Make(px - 2, (-py + 2), 0);
	[tetromino prepareWithTetromino:1];
	[tetromino setColor:1];
	[tetromino setRotation:1];
	
	[tetromino attachToObject:scene];
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

- (IBAction)left:(id)sender
{
	if (px > 0) px -= 1;
	tetromino.position = GLKVector3Make(px - 2, (-py + 2), 0);
}

- (IBAction)right:(id)sender
{
	if (px + tetromino.width < 4) px += 1;
	tetromino.position = GLKVector3Make(px - 2, (-py + 2), 0);
}

- (IBAction)up:(id)sender
{
	if (py > 0) py -= 1;
	tetromino.position = GLKVector3Make(px - 2, (-py + 2), 0);
}

- (IBAction)down:(id)sender
{
	if (py + tetromino.height < 4) py += 1;
	tetromino.position = GLKVector3Make(px - 2, (-py + 2), 0);
}

- (IBAction)drop:(id)sender
{
	BOOL allowed = YES;
	
	for (NSInteger i = 0; i < tetromino.dotCount; i++)
	{
		CGPoint p = [tetromino dotAtIndex:i];
		NSInteger c = tetromino.color;
				
		CMYKTileStack *t = tiles[(int)p.x + px][(int)p.y + py];
		
		if (c == 0 && t.l1) allowed = NO;
		if (c == 1 && t.l2) allowed = NO;
		if (c == 2 && t.l3) allowed = NO;
	}

	if (!allowed) return;
	
	for (NSInteger i = 0; i < tetromino.dotCount; i++)
	{
		CGPoint p = [tetromino dotAtIndex:i];
		NSInteger c = tetromino.color;
		
		NSLog(@"p.x: %d, p.y: %d", (int)p.x, (int)p.y);
		NSLog(@"px: %d, py: %d", px, py);
		
		CMYKTileStack *t = tiles[(int)p.x + px][(int)p.y + py];
		
		if (c == 0) t.l1 = YES;
		if (c == 1) t.l2 = YES;
		if (c == 2) t.l3 = YES;
	}
	
	for (int x = 0; x < 5; x++)
	{
		for (int y = 0; y < 5; y++)
		{
			CMYKTileStack *stack = tiles[x][y];
			if (stack.l1 && stack.l2 && stack.l3)
			{
				stack.l1 = NO;
				stack.l2 = NO;
				stack.l3 = NO;
			}
		}
	}
	
	[tetromino prepareWithTetromino:arc4random()];
	[tetromino setRotation:arc4random()];
	[tetromino setColor:arc4random()];
	
	px = py = 0;
	tetromino.position = GLKVector3Make(px - 2, (-py + 2), 0);
}


- (IBAction)rotate:(id)sender
{
	[tetromino rotateRight];
	
	if (px + tetromino.width > 4) px = 4 - tetromino.width;
	if (py + tetromino.height > 4) py = 4 - tetromino.height;
	
	tetromino.position = GLKVector3Make(px - 2, (-py + 2), 0);
}

@end
