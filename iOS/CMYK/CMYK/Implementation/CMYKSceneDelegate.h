//
//  CMYKSceneDelegate.h
//  CMYK
//
//  Created by Emiel Lensink on 25/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMYKSceneDelegate <NSObject>

- (void)becomeIdle;
- (void)becomeActive;

- (void)gameCompletedWithScore:(NSUInteger)score;
- (void)achievementObtained:(NSInteger)achievement;

@end
