//
//  CMYKTetromino.m
//  CMYK
//
//  Created by Emiel Lensink on 10/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "CMYKTetromino.h"

#import "../QX3D/QX3DObject.h"
#import "../QX3D/QX3DMaterial.h"

#import "CMYKTileStack.h"
#import "CMYKTetrominoData.h"

@interface CMYKTetromino ()
{
	NSUInteger w;
	NSUInteger h;

	NSUInteger t;		// Base tetromino (0-6)
	NSUInteger o;		// Rotation (0-3)
	NSUInteger c;		// Color (0-2)
	
	NSUInteger dc;		// Dot count
	
	CMYKTileStack *objects[4];
}

@end

@implementation CMYKTetromino

- (instancetype)initWithMaterial:(QX3DMaterial *)material
{
    self = [super init];
    if (self)
	{
		self.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
		
        for (int i = 0; i < 4; i++)
		{
			CMYKTileStack *obj = [[CMYKTileStack alloc] initWithMaterial:material];
			obj.position = GLKVector3Make(0, 0, 0);
			obj.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
			[obj attachToObject:self];
			
			objects[i] = obj;
		}
    }
    return self;
}

- (NSUInteger)width
{
	return w;
}

- (NSUInteger)height
{
	return h;
}

- (NSUInteger)color
{
	return c;
}

- (NSUInteger)dotCount
{
	return dc;
}

- (CGPoint)dotAtIndex:(NSUInteger)index
{
	GLKVector3 v = objects[index].position;
	
	return CGPointMake(v.x, -v.y);
}

- (void)prepareWithTetromino:(NSUInteger)tetromino
{
	t = abs(tetromino) % 7;
	[self updateContents];
}

- (void)setRotation:(NSUInteger)rotation
{
	o = rotation % 4;
	[self updateContents];
}

- (void)setColor:(NSUInteger)color
{
	c = color % 3;
	[self updateContents];
}

- (void)rotateRight
{
	o = (o + 1) % 4;
	[self updateContents];
}

- (void)updateContents
{
	for (int i = 0; i < 4; i++)
	{
		CMYKTileStack *obj = objects[i];
		[obj detach];
		
		if (c == 0) { obj.l1 = YES; obj.l2 = NO; obj.l3 = NO; }
		if (c == 1) { obj.l1 = NO; obj.l2 = YES; obj.l3 = NO; }
		if (c == 2) { obj.l1 = NO; obj.l2 = NO; obj.l3 = YES; }
	}
	
	int object = 0;
	
	w = 0;
	h = 0;
	
	for (int y = 0; y < 3; y++)
	{
		for (int x = 0; x < 3; x++)
		{
			if ([CMYKTetrominoData tetrominoValueForTetromino:t withRotation:o x:x y:y])
			{
				objects[object].position = GLKVector3Make(x, -y, 0);
				[objects[object] attachToObject:self];
				object++;
				if (object > 4)
				{
					NSLog(@"ehm");
				}
				if (x > w) w = x;
				if (y > h) h = y;
			}
		}
	}
	
	dc = object;
}

@end
