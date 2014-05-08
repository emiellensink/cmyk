//
//  CMYKRenderableDigit.h
//  CMYK
//
//  Created by Emiel Lensink on 04/05/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "QX3DRenderable.h"
#import "CMYKRenderableTexturedSquare.h"

@interface CMYKRenderableDigit : CMYKRenderableTexturedSquare

- (void)setDigitTextures:(NSArray *)textures;		// Array of GLKTextureInfo objects

- (void)switchToDigit:(NSInteger)digit;
- (void)switchToDigit:(NSInteger)digit animated:(BOOL)animated;

@end
