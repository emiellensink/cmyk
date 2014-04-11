//
//  CMYKTetrominoData.m
//  CMYK
//
//  Created by Emiel Lensink on 11/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "CMYKTetrominoData.h"

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

@implementation CMYKTetrominoData

+ (BOOL)tetrominoValueForTetromino:(NSUInteger)tetromino withRotation:(NSUInteger)rotation x:(NSUInteger)x y:(NSUInteger)y
{
	BOOL res = NO;
	
	NSUInteger block = tetromino * 12 + rotation;
	NSUInteger line = y;
	NSUInteger inLine = x;
	
	char *data = tetrominos[block + line * 4];
	res = (data[inLine] == 'x');
	
	return res;
}

@end
