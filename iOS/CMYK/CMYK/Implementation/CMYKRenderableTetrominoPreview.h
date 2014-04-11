//
//  CMYKRenderableTetrominoPreview.h
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "../QX3D/QX3DRenderable.h"

@interface CMYKRenderableTetrominoPreview : QX3DRenderable

//@property (nonatomic, strong) UIColor *color;

- (void)prepareWithTetromino:(NSUInteger)tetromino;
- (void)setColor:(NSUInteger)color;

@property (nonatomic, readonly) NSUInteger tetromino;
@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;
@property (nonatomic, readonly) NSUInteger color;

@end
