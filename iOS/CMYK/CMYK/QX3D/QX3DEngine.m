//
//  QX3DEngine.m
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "QX3DEngine.h"

#import "QX3DScene.h"

@interface QX3DEngine ()
{
	
}

@property (nonatomic, strong) QX3DScene *scene;

@end

@implementation QX3DEngine

+ (instancetype)engineWithScene:(QX3DScene *)scene
{
	return [[QX3DEngine alloc] initWithScene:scene];
}

- (instancetype)initWithScene:(QX3DScene *)scene
{
    self = [super init];
    if (self)
	{
        self.scene = scene;
    }
    return self;
}

- (void)updateWithView:(UIView *)view interval:(NSTimeInterval)timeSinceLastUpdate
{
	[self.scene updateWithSize:view.bounds.size interval:timeSinceLastUpdate];
}

- (void)renderInView:(UIView *)view rect:(CGRect)rect
{
	[self.scene prepareForRendering];
}

- (void)setupGL
{
	
}

- (void)cleanupGL
{
	
}

@end
