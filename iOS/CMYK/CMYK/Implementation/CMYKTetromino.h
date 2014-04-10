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

- (void)prepareWithTetromino:(NSInteger)tetromino;
- (void)setRotation:(NSInteger)rotation;
- (void)setColor:(NSInteger)color;

- (void)rotateRight;

@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;
@property (nonatomic, readonly) NSInteger color;

@property (nonatomic, readonly) NSInteger dotCount;
- (CGPoint)dotAtIndex:(NSInteger)index;


@end
