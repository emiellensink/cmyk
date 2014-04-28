//
//  CMYKScene.h
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "QX3DScene.h"
#import "CMYKSceneDelegate.h"

@interface CMYKScene : QX3DScene

- (void)beginTrackingFromButton:(NSUInteger)index withFrameSize:(CGSize)size position:(CGPoint)position;
- (void)beginTrackingWithFrameSize:(CGSize)size position:(CGPoint)position;
- (void)endTrackingWithFrameSize:(CGSize)size position:(CGPoint)position;
- (void)cancelTracking;
- (void)moveTrackingWithFrameSize:(CGSize)size position:(CGPoint)position;

- (void)restartGame;

@property (nonatomic, weak) id<CMYKSceneDelegate> delegate;

@end
