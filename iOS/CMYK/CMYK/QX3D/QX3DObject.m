//
//  QX3DObject.m
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "QX3DObject.h"
#import "QX3DObjectInternals.h"

#import "QX3DAnimator.h"

#import "QX3DScene.h"
#import "QX3DSceneInternals.h"

#import "QX3DRenderable.h"
#import "QX3DRenderableInternals.h"

@interface QX3DObject ()
{
	
}

@property (nonatomic, weak) id target;
@property (nonatomic, assign) BOOL targetIsSceneObject;

@end

@implementation QX3DObject

- (instancetype)init
{
    self = [super init];
    if (self)
	{
        self.internalObjects = [NSMutableArray array];
		self.internalRenderables = [NSMutableArray array];
		self.internalAnimators = [NSMutableArray array];
		
		self.scale = 1.0f;
    }
    return self;
}

- (NSArray *)objects
{
	return self.internalObjects;
}

- (NSArray *)animators
{
	return self.internalAnimators;
}

- (NSArray *)renderables
{
	return self.internalRenderables;
}

- (void)updateWithInterval:(NSTimeInterval)timeInterval
{
	GLKMatrix4 baseMatrix;
	if (!self.targetIsSceneObject)
	{
		baseMatrix = ((QX3DObject *)self.target).intermediateMatrix;
	}
	else
	{
		QX3DScene *scene = (QX3DScene *)self.target;
		
		baseMatrix = scene.baseModelViewMatrix;
		baseMatrix = GLKMatrix4Multiply(scene.projectionMatrix, baseMatrix);	// Not sure if this is the right order!
	}
	
	GLKVector3 v = self.position;
	baseMatrix = GLKMatrix4Multiply(baseMatrix, GLKMatrix4MakeTranslation(v.x, v.y, v.z));
	baseMatrix = GLKMatrix4Multiply(baseMatrix, GLKMatrix4MakeWithQuaternion(self.orientation));

	if (self.scale != 1.0f)
	{
		CGFloat scale = self.scale;
		baseMatrix = GLKMatrix4Multiply(baseMatrix, GLKMatrix4MakeScale(scale, scale, scale));
	}
	
	self.intermediateMatrix = baseMatrix;
	
	// Update animators (they can change all the object's properties)
	[self.animators enumerateObjectsUsingBlock:^(QX3DAnimator *obj, NSUInteger idx, BOOL *stop) {
		[obj updateWithInterval:timeInterval];
	}];
	
	// Update children
	[self.objects enumerateObjectsUsingBlock:^(QX3DObject *obj, NSUInteger idx, BOOL *stop) {
		[obj updateWithInterval:timeInterval];
	}];
}

- (void)drawRenderables
{
	[self.renderables enumerateObjectsUsingBlock:^(QX3DRenderable *obj, NSUInteger idx, BOOL *stop) {
		[obj renderWithMatrix:self.intermediateMatrix];
	}];
	
	// Render children
	[self.objects enumerateObjectsUsingBlock:^(QX3DObject *obj, NSUInteger idx, BOOL *stop) {
		[obj drawRenderables];
	}];
}

- (void)detach
{
	if (self.target)
	{
		if (self.targetIsSceneObject)
		{
			QX3DScene *scene = self.target;
			[scene.internalObjects removeObject:self];
		}
		else
		{
			QX3DObject *obj = self.target;
			[obj.internalObjects removeObject:self];
		}
		
		self.target = nil;
		self.targetIsSceneObject = NO;
	}
}

- (void)attachToObject:(id)object
{
	[self detach];
	
	if ([object isKindOfClass:[QX3DObject class]])
	{
		QX3DObject *obj = object;
		[obj.internalObjects addObject:self];
	}
	else if ([object isKindOfClass:[QX3DScene class]])
	{
		QX3DScene *scene = object;
		[scene.internalObjects addObject:self];
		self.targetIsSceneObject = YES;
	}
	else
	{
		NSException *ex = [NSException exceptionWithName:@"INVALID_TARGET" reason:@"Can't attach to this type of object" userInfo:nil];
		@throw ex;
	}
	
	self.target = object;
}

@end
