//
//  CMYKRenderableTexturedSquare.m
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "CMYKRenderableTexturedSquare.h"

#import "../QX3D/QX3DMaterial.h"
#import "../QX3D/QX3DObject.h"

#import <GLKit/GLKit.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

GLfloat gTSquareVD[30] =
{
	 0.5,  0.5,  0,  1.0,  1.0,
	-0.5,  0.5,  0,  0.0,  1.0,
	-0.5, -0.5,  0,  0.0,  0.0,
	
	 0.5,  0.5,  0,  1.0,  1.0,
	-0.5, -0.5,  0,  0.0,  0.0,
	 0.5, -0.5,  0,  1.0,  0.0
};

@interface CMYKRenderableTexturedSquareBuffer : NSObject
{
@public
	GLuint triangleArray;
	GLuint triangleBuffer;
}

@end

@implementation CMYKRenderableTexturedSquareBuffer

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

@interface CMYKRenderableTexturedSquare ()
{
	NSString *_texture;
	CGFloat screenScale;
}

@property (nonatomic, strong) GLKTextureInfo *ti;

@end

@implementation CMYKRenderableTexturedSquare

- (instancetype)initWithObject:(QX3DObject *)object
{
	if (self = [super initWithObject:object])
	{
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			
			CMYKRenderableTexturedSquareBuffer *buf = [CMYKRenderableTexturedSquareBuffer sharedBuffer];
			
			glGenVertexArraysOES(1, &buf->triangleArray);
			glBindVertexArrayOES(buf->triangleArray);
			
			glGenBuffers(1, &buf->triangleBuffer);
			glBindBuffer(GL_ARRAY_BUFFER, buf->triangleBuffer);
			glBufferData(GL_ARRAY_BUFFER, sizeof(gTSquareVD), gTSquareVD, GL_STATIC_DRAW);
			
			glEnableVertexAttribArray(GLKVertexAttribPosition);
			glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), 0);
			
			glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
			glVertexAttribPointer(GLKVertexAttribTexCoord0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), BUFFER_OFFSET(sizeof(GLfloat) * 3));
			
			glBindVertexArrayOES(0);
		});
		
		screenScale = 2.0;			// If we always feed it retina gfx, this will work.
	}
	
	return self;
}

- (void)setGlkTexture:(GLKTextureInfo *)glkTexture
{
	_ti = glkTexture;
	_texture = nil;
}

- (GLKTextureInfo *)glkTexture
{
	return _ti;
}

- (void)setTexture:(NSString *)texture
{
	_texture = texture;
	
	NSError *err;
	
	NSString *texPath = [[NSBundle mainBundle] pathForResource:texture ofType:@"png"];
	self.ti = [GLKTextureLoader textureWithContentsOfFile:texPath options:@{GLKTextureLoaderOriginBottomLeft: @(YES)} error:&err];
}

- (NSString *)texture
{
	return _texture;
}

- (void)renderWithMatrix:(GLKMatrix4)matrix
{
	CMYKRenderableTexturedSquareBuffer *buf = [CMYKRenderableTexturedSquareBuffer sharedBuffer];
	
	GLuint width = self.ti.width / screenScale;
	GLuint height = self.ti.height / screenScale;
	
	matrix = GLKMatrix4Multiply(matrix, GLKMatrix4MakeScale(width, height, 1));
	
	[super renderWithMatrix:matrix];
	
    glBindVertexArrayOES(buf->triangleArray);
    
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	GLint matrixUni = [self.material uniformForParameter:@"modelViewProjectionMatrix"];
	GLint texUni = [self.material uniformForParameter:@"colorTexture"];

	GLuint texture = self.ti.name;
	
	glUniformMatrix4fv(matrixUni, 1, 0, matrix.m);
	glUniform1i(texUni, 0);
	
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, texture);
	
	glDrawArrays(GL_TRIANGLES, 0, 6);
	
	glDisable(GL_BLEND);
}

@end
