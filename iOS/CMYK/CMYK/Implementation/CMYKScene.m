//
//  CMYKScene.m
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "CMYKScene.h"

#import <GLKit/GLKit.h>

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

- (void)updateWithSize:(CGSize)size interval:(NSTimeInterval)timeSinceLastUpdate
{
//	float range = 3;
//	float aspect = fabsf(size.height / size.width);
	float rangeX = size.width / 2.0;
	float rangeY = size.height / 2.0;
    self.projectionMatrix = GLKMatrix4MakeOrtho(-rangeX, rangeX, -rangeY, rangeY, -100, 100);

	[super updateWithSize:size interval:timeSinceLastUpdate];
}

- (void)prepareForRendering
{
	[super prepareForRendering];
	
	glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

@end
