//
//  CMYKRotationAnimator.m
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "CMYKRotationAnimator.h"

#import "../QX3D/QX3DObject.h"

@import GLKit;

@interface CMYKRotationAnimator ()
{
	GLfloat r;
}

@end

@implementation CMYKRotationAnimator

- (void)updateWithInterval:(NSTimeInterval)timeInterval
{
	QX3DObject *target = self.target;
	r += timeInterval * self.speed;
	
	GLKQuaternion quat = GLKQuaternionMakeWithAngleAndAxis(r, 0, 0, 1);

	target.intermediateMatrix = GLKMatrix4Multiply(target.intermediateMatrix, GLKMatrix4MakeWithQuaternion(quat));
}

@end
