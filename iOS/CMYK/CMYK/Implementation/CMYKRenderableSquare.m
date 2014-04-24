//
//  CMYKRenderableSquare.m
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "CMYKRenderableSquare.h"

#import "../QX3D/QX3DMaterial.h"
#import "../QX3D/QX3DObject.h"

#import <GLKit/GLKit.h>

GLfloat gSquareVD[18] =
{
	0.5,  0.5, 0,
	-0.5,  0.5, 0,
	-0.5, -0.5, 0,
	
	0.5,  0.5, 0,
	-0.5, -0.5, 0,
	0.5, -0.5, 0
};

@interface CMYKRenderableSquareBuffer : NSObject
{
@public
	GLuint triangleArray;
	GLuint triangleBuffer;
}

@end

@implementation CMYKRenderableSquareBuffer

+ (instancetype)sharedBuffer
{
	static id instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});

	return instance;
}

@end

@interface CMYKRenderableSquare ()
{
	/*
	GLfloat offset;
	GLfloat speed;
	GLfloat amplitude;
	 */
}

@end

@implementation CMYKRenderableSquare

- (instancetype)initWithObject:(QX3DObject *)object
{
	if (self = [super initWithObject:object])
	{
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			
			CMYKRenderableSquareBuffer *buf = [CMYKRenderableSquareBuffer sharedBuffer];
			
			glGenVertexArraysOES(1, &buf->triangleArray);
			glBindVertexArrayOES(buf->triangleArray);
			
			glGenBuffers(1, &buf->triangleBuffer);
			glBindBuffer(GL_ARRAY_BUFFER, buf->triangleBuffer);
			glBufferData(GL_ARRAY_BUFFER, sizeof(gSquareVD), gSquareVD, GL_STATIC_DRAW);
			
			glEnableVertexAttribArray(GLKVertexAttribPosition);
			glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, 0);
			
			glBindVertexArrayOES(0);
			
		});

		/*
		offset = rand() % 50;
		speed = 5;
		amplitude = 2;
		*/
	}
	
	return self;
}

- (void)renderWithMatrix:(GLKMatrix4)matrix
{
	CMYKRenderableSquareBuffer *buf = [CMYKRenderableSquareBuffer sharedBuffer];

	/*
	// Jiggle...
	offset += speed;
	GLfloat dx = sin(offset / 10.0) * (amplitude / 100.0);
	GLfloat dy = cos(offset / 10.0) * (amplitude / 100.0);

	matrix = GLKMatrix4Multiply(matrix, GLKMatrix4MakeTranslation(dx, dy, 0));
	*/
	
	[super renderWithMatrix:matrix];
	
    glBindVertexArrayOES(buf->triangleArray);
    
	GLint matrixUni = [self.material uniformForParameter:@"modelViewProjectionMatrix"];
	GLint colorUni = [self.material uniformForParameter:@"color"];
	
	glUniformMatrix4fv(matrixUni, 1, 0, matrix.m);
	
	CGFloat r, g, b, a;
	[self.color getRed:&r green:&g blue:&b alpha:&a];
	
	glUniform4f(colorUni, r, g, b, a);
	
	glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
