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

char *tetrominos[] =
{
	"oxo", "xxo", "oxo", "xxo",
	"xxo", "oxx", "xxo", "oxx",
	"xoo", "ooo", "xoo", "ooo",
	
	"xoo", "oxx", "xoo", "oxx",
	"xxo", "xxo", "xxo", "xxo",
	"oxo", "ooo", "oxo", "ooo",
	
	"xoo", "xxx", "xxo", "oox",
	"xoo", "xoo", "oxo", "xxx",
	"xxo", "ooo", "oxo", "ooo",
	
	"oxo", "xoo", "xxo", "xxx",
	"oxo", "xxx", "xoo", "oox",
	"xxo", "ooo", "xoo", "ooo",
	
	"xoo", "xxx", "xoo", "xxx",
	"xoo", "ooo", "xoo", "ooo",
	"xoo", "ooo", "xoo", "ooo",
	
	"xxo", "xxo", "xxo", "xxo",
	"xxo", "xxo", "xxo", "xxo",
	"ooo", "ooo", "ooo", "ooo",
	
	"xoo", "xxx", "oxo", "oxo",
	"xxo", "oxo", "xxo", "xxx",
	"xoo", "ooo", "oxo", "ooo",
};

@interface CMYKTetromino ()
{
	NSInteger w;
	NSInteger h;

	NSInteger t;		// Base tetromino (0-6)
	NSInteger o;		// Rotation (0-3)
	NSInteger c;		// Color (0-2)
	
	NSInteger dc;		// Dot count
	
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

- (NSInteger)width
{
	return w;
}

- (NSInteger)height
{
	return h;
}

- (NSInteger)color
{
	return c;
}

- (NSInteger)dotCount
{
	return dc;
}

- (CGPoint)dotAtIndex:(NSInteger)index
{
	GLKVector3 v = objects[index].position;
	
	return CGPointMake(v.x, -v.y);
}

- (void)prepareWithTetromino:(NSInteger)tetromino
{
	t = tetromino % 7;
	[self updateContents];
}

- (void)setRotation:(NSInteger)rotation
{
	o = rotation % 4;
	[self updateContents];
}

- (void)setColor:(NSInteger)color
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
	
	int offset = t * 12 + o;
	int object = 0;
	
	w = 0;
	h = 0;
	
	for (int y = 0; y < 3; y++)
	{
		char *line = tetrominos[offset + y * 4];
		
		for (int x = 0; x < 3; x++)
		{
			if (line[x] == 'x')
			{
				objects[object].position = GLKVector3Make(x, -y, 0);
				[objects[object] attachToObject:self];
				object++;
				if (x > w) w = x;
				if (y > h) h = y;
			}
		}
	}
	
	dc = object;
}

@end
