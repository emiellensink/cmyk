//
//  QX3DObject.h
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

@import Foundation;
@import GLKit;

@interface QX3DObject : NSObject

@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic, assign) GLKQuaternion orientation;
@property (nonatomic, assign) GLfloat scale;

@property (nonatomic, readonly) NSArray *renderables;
@property (nonatomic, readonly) NSArray *animators;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, readonly) NSArray *objects;

- (void)detach;
- (void)attachToObject:(id)object;

// For use by animators and for rendering...
@property (nonatomic, assign) GLKMatrix4 intermediateMatrix;

@end
