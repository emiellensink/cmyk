//
//  CMYKScene.m
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "CMYKScene.h"

#import <GLKit/GLKit.h>

#import "../QX3D/QX3DObject.h"
#import "../QX3D/QX3DMaterial.h"

#import "CMYKRenderableSquare.h"
#import "CMYKRotationAnimator.h"
#import "CMYKWaveAnimator.h"

#import "CMYKTileStack.h"
#import "CMYKTetromino.h"

#import "CMYKRenderableTexturedSquare.h"

#define PI 3.141592654

@interface CMYKScene ()
{
	CMYKTileStack *tiles[5][5];
	CMYKTetromino *tetromino;
	
	QX3DObject *scale;
	
	int px;
	int py;
	
	CGSize size;
	
	GLKTextureInfo *tetrominoTextures[7];
	GLKTextureInfo *colorCircles[3];
	
	QX3DObject *sources[4];
	CMYKRenderableTexturedSquare *sourceCircleMaterials[4];
	CMYKRenderableTexturedSquare *sourceTetrominoMaterials[4];
	NSUInteger sourcerotations[4];
	NSUInteger sourcecolors[4];
	NSUInteger sourcetetrominos[4];
	
	BOOL trackingFromButton;
	NSUInteger trackingButtonIndex;
	
	CGPoint startPoint;
	
	GLfloat rotation;
	GLfloat targetRotation;
	GLfloat buttonY[4];
	GLfloat buttonTargetY[4];
	
	BOOL finalizingRotation;
}

@end

@implementation CMYKScene

- (instancetype)init
{
    self = [super init];
    if (self)
	{
		self.baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    }
    return self;
}

- (void)updateWithSize:(CGSize)_size interval:(NSTimeInterval)timeSinceLastUpdate
{
	size = _size;
	
	float rangeX = size.width / 2.0;
	float rangeY = size.height / 2.0;
    self.projectionMatrix = GLKMatrix4MakeOrtho(-rangeX, rangeX, -rangeY, rangeY, -100, 100);

	scale.scale = rangeX / 3.0;
	tetromino.scale = rangeX / 3.0;
	
	if (targetRotation > rotation) rotation += ((targetRotation - rotation) / 5.0);
	if (targetRotation < rotation) rotation -= ((rotation - targetRotation) / 5.0);
	
	if (finalizingRotation && fabs(targetRotation - rotation) < 0.01)
	{
		NSLog(@"finalizing complete");
		
		[self normalizeRotationWithTarget:targetRotation];
		
		rotation = 0;
		targetRotation = 0;
		finalizingRotation = NO;
	}
	
	scale.orientation = GLKQuaternionMakeWithAngleAndAxis(rotation, 0, 0, 1);
	
	for (NSInteger i = 0; i < 4; i++)
	{
		if (buttonTargetY[i] > buttonY[i]) buttonY[i] += ((buttonTargetY[i] - buttonY[i]) / 7.0);
		if (buttonTargetY[i] < buttonY[i]) buttonY[i] -= ((buttonY[i] - buttonTargetY[i]) / 7.0);
		
		sources[i].position = GLKVector3Make(sources[i].position.x, buttonY[i], 0);
	}
	
	[super updateWithSize:size interval:timeSinceLastUpdate];
}

- (void)normalizeRotationWithTarget:(GLfloat)target
{
	char temp[5][5];
	char res[5][5];
	
	for (NSInteger x = 0; x < 5; x++)
	{
		for (NSInteger y = 0; y < 5; y++)
		{
			char l1 = tiles[x][y].l1 ? 1 : 0;
			char l2 = tiles[x][y].l2 ? 1 : 0;
			char l3 = tiles[x][y].l3 ? 1 : 0;
			char t = l1 | (l2 << 1) | (l3 << 2);
			
			temp[x][y] = t;
		}
	}
		
	if (target < -0.25 * PI && target > -0.75 * PI)
	{
		// rotate right
		for (NSInteger x = 0; x < 5; x++)
		{
			for (NSInteger y = 0; y < 5; y++)
			{
				res[4 - y][x] = temp[x][y];
			}
		}
	}
	
	if (target > 0.25 * PI && target < 0.75 * PI)
	{
		// rotate left
		for (NSInteger x = 0; x < 5; x++)
		{
			for (NSInteger y = 0; y < 5; y++)
			{
				res[y][4 - x] = temp[x][y];
			}
		}
	}
		
	if (target >= -0.25 * PI && target <= 0.25 * PI)
	{
		for (NSInteger x = 0; x < 5; x++)
		{
			for (NSInteger y = 0; y < 5; y++)
			{
				res[x][y] = temp[x][y];
			}
		}
	}
		
	if (target <= -0.75 * PI || target >= 0.75 * PI)
	{
		// rotate left twice
		for (NSInteger x = 0; x < 5; x++)
		{
			for (NSInteger y = 0; y < 5; y++)
			{
				res[4 - x][4 - y] = temp[x][y];
			}
		}
	}
	
	for (NSInteger x = 0; x < 5; x++)
	{
		for (NSInteger y = 0; y < 5; y++)
		{
			char l1 = res[x][y] & 1;
			char l2 = res[x][y] & (1 << 1);
			char l3 = res[x][y] & (1 << 2);
			
			tiles[x][y].l1 = l1;
			tiles[x][y].l2 = l2;
			tiles[x][y].l3 = l3;
		}
	}
}

- (void)prepareForRendering
{
	[super prepareForRendering];
	
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

- (void)initializeWithSize:(CGSize)newSize
{
	size = newSize;
	
	for (int i = 0; i < 7; i++)
	{
		NSString *name = [NSString stringWithFormat:@"tetromino%d@2x", i];
		
		NSError *err;
		
		NSString *texPath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
		tetrominoTextures[i] = [GLKTextureLoader textureWithContentsOfFile:texPath options:@{GLKTextureLoaderOriginBottomLeft: @(YES)} error:&err];
	}
	
	NSArray *arr = @[@"cyan_circle@2x", @"magenta_circle@2x", @"yellow_circle@2x"];
	[arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSError *err;
		
		NSString *texPath = [[NSBundle mainBundle] pathForResource:obj ofType:@"png"];
		colorCircles[idx] = [GLKTextureLoader textureWithContentsOfFile:texPath options:@{GLKTextureLoaderOriginBottomLeft: @(YES)} error:&err];
	}];
	
	QX3DMaterial *flatmat = [QX3DMaterial materialWithVertexProgram:@"simplevertex" pixelProgram:@"flatcolor" attributes:@{@"position": @(GLKVertexAttribPosition)}];
	
	QX3DMaterial *colormat = [QX3DMaterial materialWithVertexProgram:@"simplevertex" pixelProgram:@"subtractive" attributes:@{@"position": @(GLKVertexAttribPosition)}];
	
	QX3DMaterial *texturemat = [QX3DMaterial materialWithVertexProgram:@"texturedvertex" pixelProgram:@"textured" attributes:@{@"position": @(GLKVertexAttribPosition), @"texturecoordinate": @(GLKVertexAttribTexCoord0)}];

	scale = [QX3DObject new];
	scale.orientation = GLKQuaternionMakeWithAngleAndAxis(rotation, 0, 0, 1);
	scale.position = GLKVector3Make(0, 0, 0);
	[scale attachToObject:self];
	
	for (int x = -2; x <= 2; x++)
	{
		for (int y = -2; y <= 2; y++)
		{
			QX3DObject *obj = [QX3DObject new];
			obj.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
			obj.position = GLKVector3Make(x * 1.1, -y * 1.1, 0);
			
			CMYKRenderableSquare *square = [CMYKRenderableSquare renderableForObject:obj];
			square.color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
			
			square.material = flatmat;
			[obj attachToObject:scale];
			
			CMYKTileStack *stack = [[CMYKTileStack alloc] initWithMaterial:colormat];
			stack.position = GLKVector3Make(x * 1.1, -y * 1.1, 0);
			
			stack.l1 = x % 3;
			stack.l2 = (x == 2);
			stack.l3 = (y == 1);
			
			[stack attachToObject:scale];
			
			tiles[x + 2][y + 2] = stack;
		}
	}

	tetromino = [[CMYKTetromino alloc] initWithMaterial:colormat];
	[tetromino setRotation:0];
//	[tetromino attachToObject:self];
	
	for (NSInteger i = 0; i < 4; i++)
	{
		QX3DObject *obj = [QX3DObject new];
		obj.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
		obj.position = GLKVector3Make(-111 + (i * 74), -500, 0);
		sources[i] = obj;
		
		buttonY[i] = -500;
		buttonTargetY[i] = (-size.height / 2.0) + 40.0;
		
		NSLog(@"%f", (-size.height / 2.0) + 40.0);
		
		NSInteger random3 = arc4random() % 3;
		NSInteger random7 = arc4random() % 7;
		
		CMYKRenderableTexturedSquare *s = [CMYKRenderableTexturedSquare renderableForObject:obj];
		s.material = texturemat;
		s.glkTexture = colorCircles[random3];
		sourceCircleMaterials[i] = s;
		sourcecolors[i] = random3;
		
		CMYKRenderableTexturedSquare *t = [CMYKRenderableTexturedSquare renderableForObject:obj];
		t.material = texturemat;
		t.glkTexture = tetrominoTextures[random7];
		sourceTetrominoMaterials[i] = t;
		sourcetetrominos[i] = random7;
		
		[obj attachToObject:self];
	}
}

/*
- (void)drop:(id)sender
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
*/

- (void)beginTrackingFromButton:(NSUInteger)index withFrameSize:(CGSize)newSize position:(CGPoint)position
{
	trackingFromButton = YES;
	trackingButtonIndex = index;
	
	[tetromino prepareWithTetromino:sourcetetrominos[trackingButtonIndex]];
	[tetromino setColor:sourcecolors[trackingButtonIndex]];
	[tetromino attachToObject:self];
	
	float rangeX = size.width / 2.0;
	float rangeY = size.height / 2.0;
	
	tetromino.position = GLKVector3Make(position.x - rangeX, (size.height - position.y) - rangeY, 0);
	
	buttonTargetY[trackingButtonIndex] = (-size.height / 2.0) - 100.0;
}

- (void)beginTrackingWithFrameSize:(CGSize)size position:(CGPoint)position
{
	trackingFromButton = NO;
	startPoint = position;
}

- (void)endTrackingWithFrameSize:(CGSize)newSize position:(CGPoint)position
{
	if (!trackingFromButton)
	{
		if (!finalizingRotation)
		{
			NSLog(@"%f", targetRotation);
			
			if (targetRotation < -0.25 * PI && targetRotation > -0.75 * PI)
				targetRotation = -0.5 * PI;
			if (targetRotation > 0.25 * PI && targetRotation < 0.75 * PI)
				targetRotation = 0.5 * PI;
			if (targetRotation >= -0.25 * PI && targetRotation <= 0.25 * PI)
				targetRotation = 0;
			if (targetRotation <= -0.75 * PI) targetRotation = -PI;
			if (targetRotation >= 0.75 * PI) targetRotation = PI;
			
			finalizingRotation = YES;
			trackingFromButton = NO;
		}
	}
	else
	{
		// Initialize button with new values
		
		NSInteger random3 = arc4random() % 3;
		NSInteger random7 = arc4random() % 7;
		
		sourceCircleMaterials[trackingButtonIndex].glkTexture = colorCircles[random3];
		sourcecolors[trackingButtonIndex] = random3;
		
		sourceTetrominoMaterials[trackingButtonIndex].glkTexture = tetrominoTextures[random7];
		sourcetetrominos[trackingButtonIndex] = random7;
				
		[tetromino detach];
		
		buttonTargetY[trackingButtonIndex] = (-size.height / 2.0) + 40.0;
	}
}

- (void)moveTrackingWithFrameSize:(CGSize)newSize position:(CGPoint)position
{
	if (!trackingFromButton)
	{
		if (!finalizingRotation)
		{
			targetRotation -= (position.x - startPoint.x) / 100.0;
			startPoint = position;
		}
	}
	else
	{
		float rangeX = size.width / 2.0;
		float rangeY = size.height / 2.0;
		
		tetromino.position = GLKVector3Make(position.x - rangeX, (size.height - position.y) - rangeY, 0);
	}
}

- (void)cancelTracking
{
	if (!trackingFromButton)
	{
		if (!finalizingRotation)
		{
			NSLog(@"%f", targetRotation);
			
			if (targetRotation < -0.25 * PI && targetRotation > -0.75 * PI)
				targetRotation = -0.5 * PI;
			if (targetRotation > 0.25 * PI && targetRotation < 0.75 * PI)
				targetRotation = 0.5 * PI;
			if (targetRotation >= -0.25 * PI && targetRotation <= 0.25 * PI)
				targetRotation = 0;
			if (targetRotation <= -0.75 * PI) targetRotation = -PI;
			if (targetRotation >= 0.75 * PI) targetRotation = PI;
			
			finalizingRotation = YES;
			trackingFromButton = NO;
		}
	}
	else
	{
		// Move button to original position...
		buttonTargetY[trackingButtonIndex] = (-size.height / 2.0) + 40.0;
	}
}

@end
