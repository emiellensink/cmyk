//
//  CMYKScene.h
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "QX3DScene.h"

@interface CMYKScene : QX3DScene

- (void)left:(id)sender;
- (void)right:(id)sender;
- (void)up:(id)sender;
- (void)down:(id)sender;
- (void)drop:(id)sender;
- (void)rotate:(id)sender;

@end
