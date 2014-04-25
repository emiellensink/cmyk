//
//  QX3DMaterial.m
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "QX3DMaterial.h"

@interface QX3DMaterial ()
{
	GLuint program;
}

@property (nonatomic, strong) NSString *vertexName;
@property (nonatomic, strong) NSString *pixelName;
@property (nonatomic, strong) NSDictionary *attribLocations;

@property (nonatomic, strong) NSMutableDictionary *uniforms;

@end

@implementation QX3DMaterial

+ (instancetype)materialWithVertexProgram:(NSString *)vertexName pixelProgram:(NSString *)pixelName attributes:(NSDictionary *)attribLocations
{
	return [[self alloc] initWithVertexProgram:vertexName pixelProgram:pixelName attributes:attribLocations];
}

- (instancetype)initWithVertexProgram:(NSString *)vertexName pixelProgram:(NSString *)pixelName attributes:(NSDictionary *)attribLocations
{
    self = [super init];
    if (self)
	{
        self.vertexName = vertexName;
		self.pixelName = pixelName;
		self.attribLocations = attribLocations;
		self.uniforms = [NSMutableDictionary dictionary];
		
		[self loadShadersForVertexProgram:vertexName pixelProgram:pixelName attributes:attribLocations];
    }
    return self;
}

- (void)dealloc
{
	glDeleteProgram(program);
}

- (GLint)uniformForParameter:(NSString *)name
{
	NSNumber *num = self.uniforms[name];
	GLint res = 0;
	
	if (num) res = (GLint)[num integerValue];
	
	return res;
}

- (void)activate
{
	glUseProgram(program);
}

- (BOOL)loadShadersForVertexProgram:(NSString *)vertexName pixelProgram:(NSString *)pixelName attributes:(NSDictionary *)attribLocations
{
	GLuint vertShader, fragShader;
	NSString *vertShaderPathname, *fragShaderPathname;
	
	// Create shader program.
	program = glCreateProgram();
	
	// Create and compile vertex shader.
	vertShaderPathname = [[NSBundle mainBundle] pathForResource:vertexName ofType:@"vsh"];
	if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
	{
		NSLog(@"Failed to compile vertex shader");
		return NO;
	}
	
	// Create and compile fragment shader.
	fragShaderPathname = [[NSBundle mainBundle] pathForResource:pixelName ofType:@"fsh"];
	if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
	{
		NSLog(@"Failed to compile fragment shader");
		return NO;
	}
	
	// Attach vertex shader to program.
	glAttachShader(program, vertShader);
	
	// Attach fragment shader to program.
	glAttachShader(program, fragShader);
	
	// Bind attribute locations.
	// This needs to be done prior to linking.
	[attribLocations enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop) {
		glBindAttribLocation(program, (GLint)[obj integerValue], [key cStringUsingEncoding:NSUTF8StringEncoding]);
	}];
		
	// Link program.
	if (![self linkProgram:program]) {
		NSLog(@"Failed to link program: %d", program);
		
		if (vertShader) {
			glDeleteShader(vertShader);
			vertShader = 0;
		}
		if (fragShader) {
			glDeleteShader(fragShader);
			fragShader = 0;
		}
		if (program) {
			glDeleteProgram(program);
			program = 0;
		}
		
		return NO;
	}
	
	int total = -1;
	glGetProgramiv(program, GL_ACTIVE_UNIFORMS, &total );
	
	for (GLuint i = 0; i < total; ++i)
	{
		int name_len=-1;
		int num=-1;
		GLenum type = GL_ZERO;
		
		char name[1000];
		
		glGetActiveUniform(program, i, sizeof(name) - 1, &name_len, &num, &type, name);
		name[name_len] = 0;
		
		GLuint location = glGetUniformLocation(program, name);
		
		NSString *key = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
		NSNumber *loc = [NSNumber numberWithUnsignedInteger:location];
		
		self.uniforms[key] = loc;
	}

	// Release vertex and fragment shaders.
	if (vertShader) {
		glDetachShader(program, vertShader);
		glDeleteShader(vertShader);
	}
	if (fragShader) {
		glDetachShader(program, fragShader);
		glDeleteShader(fragShader);
	}
	
	return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
	GLint status;
	const GLchar *source;
	
	source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if (!source) {
		NSLog(@"Failed to load vertex shader");
		return NO;
	}
	
	*shader = glCreateShader(type);
	glShaderSource(*shader, 1, &source, NULL);
	glCompileShader(*shader);
	
#if defined(DEBUG)
	GLint logLength;
	glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetShaderInfoLog(*shader, logLength, &logLength, log);
		NSLog(@"Shader compile log:\n%s", log);
		free(log);
	}
#endif
	
	glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
	if (status == 0) {
		glDeleteShader(*shader);
		return NO;
	}
	
	return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
	GLint status;
	glLinkProgram(prog);
	
#if defined(DEBUG)
	GLint logLength;
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program link log:\n%s", log);
		free(log);
	}
#endif
	
	glGetProgramiv(prog, GL_LINK_STATUS, &status);
	if (status == 0) {
		return NO;
	}
	
	return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
	GLint logLength, status;
	
	glValidateProgram(prog);
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program validate log:\n%s", log);
		free(log);
	}
	
	glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
	if (status == 0) {
		return NO;
	}
	
	return YES;
}



@end
