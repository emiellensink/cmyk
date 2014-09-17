//
//  QX3DScene.h
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

@import Foundation;
@import GLKit;

@interface QX3DScene : NSObject

- (void)initializeWithSize:(CGSize)newSize;

- (void)updateWithSize:(CGSize)size interval:(NSTimeInterval)timeSinceLastUpdate;
- (void)prepareForRendering;

@property (nonatomic, assign) GLKMatrix4 projectionMatrix;
@property (nonatomic, assign) GLKMatrix4 baseModelViewMatrix;

@property (nonatomic, readonly) NSArray *objects;

@end
