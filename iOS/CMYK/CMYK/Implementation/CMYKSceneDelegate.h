//
//  CMYKSceneDelegate.h
//  CMYK
//
//  Created by Emiel Lensink on 25/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

@import Foundation;

enum CMYKAchievements
{
	CleanSlate,
	Equal,
	Played100,
	Played250,
	Played500
};

@protocol CMYKSceneDelegate <NSObject>

- (void)becomeIdle;
- (void)becomeActive;

- (void)gameCompletedWithScore:(NSUInteger)score;
- (void)achievementObtained:(enum CMYKAchievements)achievement;

@end
