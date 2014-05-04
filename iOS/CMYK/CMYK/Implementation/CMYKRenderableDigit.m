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
}

@end
