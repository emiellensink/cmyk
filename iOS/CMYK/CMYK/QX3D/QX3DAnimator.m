//
//  QX3DAnimator.m
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "QX3DAnimator.h"

#import "QX3DObject.h"
#import "QX3DObjectInternals.h"

@interface QX3DAnimator ()
{
	
}

@property (nonatomic, weak) QX3DObject *target;

@end

@implementation QX3DAnimator

+ (instancetype)animatorForObject:(QX3DObject *)object
{
	return [[self alloc] initWithObject:object];
}

- (instancetype)initWithObject:(QX3DObject *)object;
{
    self = [super init];
    if (self)
	{
		[self attachToObject:object];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
	{
        
    }
    return self;
}

- (void)detach
{
	if (self.target)
	{
		[self.target.internalAnimators removeObject:self];
		self.target = nil;
	}
}

- (void)attachToObject:(QX3DObject *)object
{
	[self detach];

	self.target = object;
	[self.target.internalAnimators addObject:self];
}

- (void)updateWithInterval:(NSTimeInterval)timeInterval
{
	
}

@end
