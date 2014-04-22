//
//  QX3DScene.m
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "QX3DScene.h"
#import "QX3DSceneInternals.h"

#import "QX3DObject.h"
#import "QX3DObjectInternals.h"

@interface QX3DScene ()
{
	
}

@end

@implementation QX3DScene

- (instancetype)init
{
    self = [super init];
    if (self)
	{
        self.internalObjects = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)objects
{
	return self.internalObjects;
}

- (void)updateWithSize:(CGSize)size interval:(NSTimeInterval)timeSinceLastUpdate
{
	[self.objects enumerateObjectsUsingBlock:^(QX3DObject *obj, NSUInteger idx, BOOL *stop) {
		[obj updateWithInterval:timeSinceLastUpdate];
	}];
}

- (void)prepareForRendering
{

}

- (void)initialize
{
	
}

@end
