//
//  QX3DObjectInternals.h
//  CMYK
//
//  Created by Emiel Lensink on 09/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

@import Foundation;
@import GLKit;

@interface QX3DObject ()

@property (nonatomic, strong) NSMutableArray *internalObjects;
@property (nonatomic, strong) NSMutableArray *internalAnimators;
@property (nonatomic, strong) NSMutableArray *internalRenderables;

- (void)updateWithInterval:(NSTimeInterval)timeInterval;
- (void)drawRenderables;

@end
