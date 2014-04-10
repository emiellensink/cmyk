//
//  CMYKTileStack.h
//  CMYK
//
//  Created by Emiel Lensink on 10/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "QX3DObject.h"

@class QX3DMaterial;

@interface CMYKTileStack : QX3DObject

- (instancetype)initWithMaterial:(QX3DMaterial *)material;

@property (nonatomic, assign) BOOL l1;
@property (nonatomic, assign) BOOL l2;
@property (nonatomic, assign) BOOL l3;

@end
