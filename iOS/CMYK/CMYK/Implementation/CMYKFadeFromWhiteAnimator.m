//
//  CMYKFadeFromWhiteAnimator.m
//  CMYK
//
//  Created by Emiel Lensink on 25/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "CMYKFadeFromWhiteAnimator.h"

#import "CMYKRenderableSquare.h"
#import "../QX3D/QX3DObject.h"

// NOTE: For this animator to work, it must have been attached to a 3d object
//  with 1 renderable, of type CMYKRenderableSquare.

@interface CMYKFadeFromWhiteAnimator ()
{
	CGFloat rgb;
	CGFloat a;

	NSTimeInterval time;
}

@end

@implementation CMYKFadeFromWhiteAnimator

- (void)updateWithInterval:(NSTimeInterval)timeInterval
{
	QX3DObject *target = self.target;
	
	CMYKRenderableSquare *square = [target.renderables firstObject];
	square.color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0 - (time * 2.0)];
	
	time += timeInterval;
	
	if (time > 0.5 && time < 100.0)
	{
		time = 110.0;
		[self performSelector:@selector(detachTargetFromScene:) withObject:self.target afterDelay:0.01];
	}
}

- (void)detachTargetFromScene:(id)detachThis
{
	QX3DObject *target = detachThis;
	[target detach];
}

@end
