//
//  CMYKDarkenAnimator.m
//  CMYK
//
//  Created by Emiel Lensink on 28/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "CMYKDarkenAnimator.h"

#import "CMYKRenderableSquare.h"
#import "../QX3D/QX3DObject.h"

// NOTE: For this animator to work, it must have been attached to a 3d object
//  with 1 renderable, of type CMYKRenderableSquare.

@interface CMYKDarkenAnimator ()
{
	NSTimeInterval time;
}

@end

@implementation CMYKDarkenAnimator

- (void)updateWithInterval:(NSTimeInterval)timeInterval
{
	QX3DObject *target = self.target;
	
	CMYKRenderableSquare *square = [target.renderables firstObject];
	square.color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:time];
	
	time += timeInterval;
	if (time > 0.8) time = 0.8;
}

@end
