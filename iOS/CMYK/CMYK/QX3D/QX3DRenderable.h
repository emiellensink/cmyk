//
//  QX3DRenderable.h
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

@import Foundation;
@import GLKit;

@class QX3DObject;
@class QX3DMaterial;

@interface QX3DRenderable : NSObject

+ (instancetype)renderableForObject:(QX3DObject *)object;
- (instancetype)initWithObject:(QX3DObject *)object;

- (void)detach;
- (void)attachToObject:(QX3DObject *)object;

- (void)renderWithMatrix:(GLKMatrix4)matrix;

@property (nonatomic, strong) QX3DMaterial *material;

@end
