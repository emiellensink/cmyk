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

@interface CMYKScene ()
{
	CMYKTileStack *tiles[5][5];
	CMYKTetromino *tetromino;
	
	QX3DObject *scale;
	
	int px;
	int py;
	
	CGSize size;
	
	GLKTextureInfo *tetrominoTextures[7];
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
	
	[super updateWithSize:size interval:timeSinceLastUpdate];
}

- (void)prepareForRendering
{
	[super prepareForRendering];
	
	glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

- (void)initialize
{
	for (int i = 0; i < 7; i++)
	{
		NSString *name = [NSString stringWithFormat:@"tetromino%d@2x", i];
		
		NSError *err;
		
		NSString *texPath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
		tetrominoTextures[i] = [GLKTextureLoader textureWithContentsOfFile:texPath options:@{GLKTextureLoaderOriginBottomLeft: @(YES)} error:&err];
	}
	
	QX3DMaterial *flatmat = [QX3DMaterial materialWithVertexProgram:@"simplevertex" pixelProgram:@"flatcolor" attributes:@{@"position": @(GLKVertexAttribPosition)}];
	
	QX3DMaterial *colormat = [QX3DMaterial materialWithVertexProgram:@"simplevertex" pixelProgram:@"subtractive" attributes:@{@"position": @(GLKVertexAttribPosition)}];
	
	QX3DMaterial *texturemat = [QX3DMaterial materialWithVertexProgram:@"texturedvertex" pixelProgram:@"textured" attributes:@{@"position": @(GLKVertexAttribPosition), @"texturecoordinate": @(GLKVertexAttribTexCoord0)}];

	scale = [QX3DObject new];
	scale.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
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
			square.color = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
			
			square.material = flatmat;
			[obj attachToObject:scale];
			
			CMYKTileStack *stack = [[CMYKTileStack alloc] initWithMaterial:colormat];
			stack.position = GLKVector3Make(x * 1.1, -y * 1.1, 0);
			
			[stack attachToObject:scale];
			
			tiles[x + 2][y + 2] = stack;
		}
	}
	
	tetromino = [[CMYKTetromino alloc] initWithMaterial:colormat];
	tetromino.position = GLKVector3Make(px - 2, (-py + 2), 0);
	[tetromino prepareWithTetromino:1];
	[tetromino setColor:1];
	[tetromino setRotation:1];
	
	[tetromino attachToObject:scale];
	
	// Texture test
	
	QX3DObject *sq = [QX3DObject new];
	sq.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
	sq.position = GLKVector3Make(0, 0, 0);

	CMYKRenderableTexturedSquare *tsq = [CMYKRenderableTexturedSquare renderableForObject:sq];
	tsq.glkTexture = tetrominoTextures[2];

	tsq.material = texturemat;
	[sq attachToObject:self];
}

- (void)left:(id)sender
{
	if (px > 0) px -= 1;
	tetromino.position = GLKVector3Make(px - 2, (-py + 2), 0);
}

- (void)right:(id)sender
{
	if (px + tetromino.width < 4) px += 1;
	tetromino.position = GLKVector3Make(px - 2, (-py + 2), 0);
}

- (void)up:(id)sender
{
	if (py > 0) py -= 1;
	tetromino.position = GLKVector3Make(px - 2, (-py + 2), 0);
}

- (void)down:(id)sender
{
	if (py + tetromino.height < 4) py += 1;
	tetromino.position = GLKVector3Make(px - 2, (-py + 2), 0);
}

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


- (void)rotate:(id)sender
{
	[tetromino rotateRight];
	
	if (px + tetromino.width > 4) px = 4 - tetromino.width;
	if (py + tetromino.height > 4) py = 4 - tetromino.height;
	
	tetromino.position = GLKVector3Make(px - 2, (-py + 2), 0);
}


@end
