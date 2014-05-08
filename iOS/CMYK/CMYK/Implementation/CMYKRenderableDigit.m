//
//  CMYKRenderableDigit.m
//  CMYK
//
//  Created by Emiel Lensink on 04/05/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "CMYKRenderableDigit.h"

@interface CMYKRenderableDigit ()
{
	NSArray *digits;
	NSInteger currentDigit;
}

@end

@implementation CMYKRenderableDigit

- (void)setDigitTextures:(NSArray *)textures
{
	digits = textures;
}

- (void)switchToDigit:(NSInteger)digit
{
	[self setGlkTexture:digits[digit]];
	currentDigit = digit;
}

- (void)switchToDigit:(NSInteger)digit animated:(BOOL)animated
{
	if (!animated)
		[self setGlkTexture:digits[digit]];
	else
	{
		// TODO: Animation
		[self setGlkTexture:digits[digit]];
	}
	
	currentDigit = digit;
}


@end
