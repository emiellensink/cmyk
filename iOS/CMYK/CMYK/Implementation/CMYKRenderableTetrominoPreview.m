//
//  CMYKRenderableTetrominoPreview.m
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "CMYKRenderableTetrominoPreview.h"

#import "../QX3D/QX3DMaterial.h"
#import "../QX3D/QX3DObject.h"

#import "CMYKTileStack.h"
#import "CMYKTetrominoData.h"

#import <GLKit/GLKit.h>

GLfloat gTetrominoPreviewVD[6 * 3 * 4] =
{
	0.5,  0.5, 0,
	-0.5,  0.5, 0,
	-0.5, -0.5, 0,
	
	0.5,  0.5, 0,
	-0.5, -0.5, 0,
	0.5, -0.5, 0,
	
	0.5,  0.5, 0,
	-0.5,  0.5, 0,
	-0.5, -0.5, 0,
	
	0.5,  0.5, 0,
	-0.5, -0.5, 0,
	0.5, -0.5, 0,

	0.5,  0.5, 0,
	-0.5,  0.5, 0,
	-0.5, -0.5, 0,
	
	0.5,  0.5, 0,
	-0.5, -0.5, 0,
	0.5, -0.5, 0,

	0.5,  0.5, 0,
	-0.5,  0.5, 0,
	-0.5, -0.5, 0,
	
	0.5,  0.5, 0,
	-0.5, -0.5, 0,
	0.5, -0.5, 0
};

@interface CMYKRenderableTetrominoPreview ()
{
	NSUInteger t;		// Base tetromino (0-6)
	NSUInteger o;		// Rotation (0-3)
	NSUInteger c;		// Color (0-2)
	
	NSUInteger dc;		// Dot count

	NSUInteger w;
	NSUInteger h;
	
	GLfloat *buffer;
	
	GLuint triangleArray;
	GLuint triangleBuffer;
}

@property (nonatomic, strong) UIColor *internalColor;

@end

@implementation CMYKRenderableTetrominoPreview

- (void)dealloc
{
	glDeleteBuffers(1, &triangleBuffer);
    glDeleteVertexArraysOES(1, &triangleArray);

	if (buffer) free(buffer);
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

- (NSUInteger)tetromino
{
	return t;
}

- (void)prepareWithTetromino:(NSUInteger)tetromino
{
	t = abs(tetromino) % 7;
	[self updateContents];
}

- (void)setColor:(NSUInteger)color
{
	c = color % 3;
	self.internalColor = [CMYKTileStack colorForLayer:c];
}

- (void)updateContents
{
	for (int i = 0; i < sizeof(gTetrominoPreviewVD) / sizeof(GLfloat); i++)
		buffer[i] = gTetrominoPreviewVD[i];

	w = h = dc = 0;
	
	for (int y = 0; y < 3; y++)
	{
		for (int x = 0; x < 3; x++)
		{
			int offset = dc * 6 * 3;
			
			if ([CMYKTetrominoData tetrominoValueForTetromino:t withRotation:o x:x y:y])
			{
				for (int i = 0; i < 6; i++)
				{
					buffer[offset] += x;
					buffer[offset + 1] += y;
					
					offset += 3;
				}

				dc++;
				if (x > w) w = x;
				if (y > h) h = y;
			}
		}
	}
}

- (void)warmup
{
	buffer = malloc(sizeof(gTetrominoPreviewVD));
	for (int i = 0; i < sizeof(gTetrominoPreviewVD) / sizeof(GLfloat); i++)
		buffer[i] = gTetrominoPreviewVD[i];
	
	glGenVertexArraysOES(1, &triangleArray);
	glBindVertexArrayOES(triangleArray);
	
	glGenBuffers(1, &triangleBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, triangleBuffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(gTetrominoPreviewVD), buffer, GL_DYNAMIC_DRAW);
	
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, 0);
	
	glBindVertexArrayOES(0);		
}

- (void)renderWithMatrix:(GLKMatrix4)matrix
{
	[super renderWithMatrix:matrix];
	
    glBindVertexArrayOES(triangleArray);
    
	GLint matrixUni = [self.material uniformForParameter:@"modelViewProjectionMatrix"];
	GLint colorUni = [self.material uniformForParameter:@"color"];
	
	glUniformMatrix4fv(matrixUni, 1, 0, matrix.m);
	
	CGFloat r, g, b, a;
	[self.internalColor getRed:&r green:&g blue:&b alpha:&a];
	
	glUniform4f(colorUni, r, g, b, a);
	
	glDrawArrays(GL_TRIANGLES, 0, 6 * dc);
}

@end
