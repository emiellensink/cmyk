//
//  CMYKWaveAnimator.h
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "QX3DAnimator.h"

@interface CMYKWaveAnimator : QX3DAnimator

@property (nonatomic, assign) GLfloat speed;
@property (nonatomic, assign) GLfloat amplitude;
@property (nonatomic, assign) GLfloat offset;

@end
