//
//  CMYKTetromino.h
//  CMYK
//
//  Created by Emiel Lensink on 10/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "QX3DObject.h"

@class QX3DMaterial;

@interface CMYKTetromino : QX3DObject

- (instancetype)initWithMaterial:(QX3DMaterial *)material;

- (void)prepareWithTetromino:(NSUInteger)tetromino;
- (void)setRotation:(NSUInteger)rotation;
- (void)setColor:(NSUInteger)color;

- (void)rotateRight;

@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;
@property (nonatomic, readonly) NSUInteger color;

@property (nonatomic, readonly) NSUInteger dotCount;
- (CGPoint)dotAtIndex:(NSUInteger)index;


@end
