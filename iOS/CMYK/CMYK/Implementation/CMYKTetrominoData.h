//
//  CMYKTetrominoData.h
//  CMYK
//
//  Created by Emiel Lensink on 11/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

@import Foundation;

@interface CMYKTetrominoData : NSObject

+ (BOOL)tetrominoValueForTetromino:(NSUInteger)tetromino withRotation:(NSUInteger)rotation x:(NSUInteger)x y:(NSUInteger)y;

@end
