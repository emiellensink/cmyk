//
//  QX3DAnimator.h
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

@import Foundation;

@class QX3DObject;

@interface QX3DAnimator : NSObject

+ (instancetype)animatorForObject:(QX3DObject *)object;
- (instancetype)initWithObject:(QX3DObject *)object;

- (void)detach;
- (void)attachToObject:(QX3DObject *)object;

- (void)updateWithInterval:(NSTimeInterval)timeInterval;

@property (nonatomic, readonly) QX3DObject *target;

@end
