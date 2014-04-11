//
//  CMYKTileStack.m
//  CMYK
//
//  Created by Emiel Lensink on 10/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "CMYKTileStack.h"

#import "CMYKRenderableSquare.h"

@interface CMYKTileStack ()
{
	BOOL _l1, _l2, _l3;
}

@property (nonatomic, strong) NSArray *layers;

@end

@implementation CMYKTileStack

- (instancetype)initWithMaterial:(QX3DMaterial *)material
{
    self = [super init];
    if (self)
	{
		self.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
		
		CMYKRenderableSquare *square1 = [CMYKRenderableSquare renderableForObject:nil];
		[square1 warmup];
		square1.color = [[self class] colorForLayer:0];
		square1.material = material;

		CMYKRenderableSquare *square2 = [CMYKRenderableSquare renderableForObject:nil];
		[square2 warmup];
		square2.color = [[self class] colorForLayer:1];
		square2.material = material;

		CMYKRenderableSquare *square3 = [CMYKRenderableSquare renderableForObject:nil];
		[square3 warmup];
		square3.color = [[self class] colorForLayer:2];
		square3.material = material;

		self.layers = @[square1, square2, square3];
	}
    return self;
}

+ (UIColor *)colorForLayer:(NSUInteger)layer
{
	UIColor *res = nil;
	
	if (layer == 0) [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1];
	if (layer == 1) [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1];
	if (layer == 2) [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1];

	return res;
}



- (BOOL)l1
{
	return _l1;
}

- (BOOL)l2
{
	return _l2;
}

- (BOOL)l3
{
	return _l3;
}

- (void)setL1:(BOOL)l
{
	_l1 = l;
	[self updateLayers];
}

- (void)setL2:(BOOL)l
{
	_l2 = l;
	[self updateLayers];
}

- (void)setL3:(BOOL)l
{
	_l3 = l;
	[self updateLayers];
}

- (void)updateLayers		// TODO: For real game, make better
{
	[self.layers enumerateObjectsUsingBlock:^(QX3DRenderable *obj, NSUInteger idx, BOOL *stop) {
		[obj detach];
	}];
	
	if (_l1) [self.layers[0] attachToObject:self];
	if (_l2) [self.layers[1] attachToObject:self];
	if (_l3) [self.layers[2] attachToObject:self];
}

@end
