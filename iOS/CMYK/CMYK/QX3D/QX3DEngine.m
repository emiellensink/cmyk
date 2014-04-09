//
//  QX3DEngine.m
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "QX3DEngine.h"

#import "QX3DScene.h"

#import "QX3DObject.h"
#import "QX3DObjectInternals.h"

@interface QX3DEngine ()
{
	
}

@property (nonatomic, strong) QX3DScene *internalScene;

@end

@implementation QX3DEngine

+ (instancetype)engineWithScene:(QX3DScene *)scene
{
	return [[self alloc] initWithScene:scene];
}

- (instancetype)initWithScene:(QX3DScene *)scene
{
    self = [super init];
    if (self)
	{
        self.internalScene = scene;
    }
    return self;
}

- (QX3DScene *)scene
{
	return self.internalScene;
}

- (void)updateWithView:(UIView *)view interval:(NSTimeInterval)timeSinceLastUpdate
{
	[self.internalScene updateWithSize:view.bounds.size interval:timeSinceLastUpdate];
}

- (void)renderInView:(UIView *)view rect:(CGRect)rect
{
	[self.internalScene prepareForRendering];
	
	[self.internalScene.objects enumerateObjectsUsingBlock:^(QX3DObject *obj, NSUInteger idx, BOOL *stop) {
		[obj drawRenderables];
	}];
}

- (void)setupGL
{
	
}

- (void)cleanupGL
{
	
}

@end
