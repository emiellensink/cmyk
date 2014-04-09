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
#import "../QX3D/QX3DObjectInternals.h"

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

@interface CMYKRenderableSquare ()
{
	GLuint triangleArray;
	GLuint triangleBuffer;
}

@end

@implementation CMYKRenderableSquare

- (void)warmup
{
	glGenVertexArraysOES(1, &triangleArray);
    glBindVertexArrayOES(triangleArray);
    
    glGenBuffers(1, &triangleBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, triangleBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gSquareVD), gSquareVD, GL_STATIC_DRAW);
    
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
	glUniform4f(colorUni, 1.0, 0.0, 0.0, 1.0);
		
	glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end
