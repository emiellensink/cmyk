//
//  CMYKWaveAnimator.m
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "CMYKWaveAnimator.h"

#import "../QX3D/QX3DObject.h"

#import <GLKit/GLKit.h>

@interface CMYKWaveAnimator ()
{
	GLfloat r;
}

@end

@implementation CMYKWaveAnimator

- (void)updateWithInterval:(NSTimeInterval)timeInterval
{
	QX3DObject *target = self.target;
	r += timeInterval * self.speed;

	GLfloat off = self.amplitude * sin(r + self.offset);
	
	target.intermediateMatrix = GLKMatrix4Multiply(target.intermediateMatrix, GLKMatrix4MakeTranslation(off, 0, 0));
}

@end
