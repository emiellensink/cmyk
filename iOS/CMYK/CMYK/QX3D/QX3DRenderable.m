//
//  QX3DRenderable.m
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "QX3DRenderable.h"
#import "QX3DRenderableInternals.h"

#import "QX3DObject.h"
#import "QX3DObjectInternals.h"

#import "QX3DMaterial.h"

@interface QX3DRenderable ()
{
	
}

@property (nonatomic, weak) QX3DObject *target;

@end

@implementation QX3DRenderable

+ (instancetype)renderableForObject:(QX3DObject *)object
{
	return [[self alloc] initWithObject:object];
}

- (instancetype)initWithObject:(QX3DObject *)object
{
    self = [super init];
    if (self)
	{
		[self attachToObject:object];
    }
    return self;
}

- (void)detach
{
	if (self.target)
	{
		[self.target.internalRenderables removeObject:self];
		self.target = nil;
	}
}

- (void)attachToObject:(QX3DObject *)object
{
	[self detach];
	
	self.target = object;
	[self.target.internalRenderables addObject:self];
}

- (void)renderWithMatrix:(GLKMatrix4)matrix
{
	[self.material activate];
}

@end
