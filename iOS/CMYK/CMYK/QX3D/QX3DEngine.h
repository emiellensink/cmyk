//
//  QX3DEngine.h
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QX3DScene;

@interface QX3DEngine : NSObject

+ (instancetype)engineWithScene:(QX3DScene *)scene;
- (instancetype)initWithScene:(QX3DScene *)scene;

- (void)updateWithView:(UIView *)view interval:(NSTimeInterval)timeSinceLastUpdate;
- (void)renderInView:(UIView *)view rect:(CGRect)rect;

- (void)setupGL;
- (void)cleanupGL;

@end
