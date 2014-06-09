//
//  ViewController.h
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>


#import "Implementation/CMYKSceneDelegate.h"

@interface ViewController : GLKViewController<CMYKSceneDelegate>

@property (nonatomic, strong) IBOutlet UIButton *b1;
@property (nonatomic, strong) IBOutlet UIButton *b2;
@property (nonatomic, strong) IBOutlet UIButton *b3;
@property (nonatomic, strong) IBOutlet UIButton *b4;

@property (nonatomic, strong) IBOutlet UIButton *restart;
@property (nonatomic, strong) IBOutlet UIButton *gameCenter;

- (IBAction)restartTapped:(id)sender;
- (IBAction)gameCenterTapped:(id)sender;


@end
