//
//  InfoViewController.h
//  CMYK
//
//  Created by Emiel Lensink on 02/05/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

@import UIKit;

@interface InfoViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *CMYKButton;
@property (nonatomic, strong) IBOutlet UIButton *RGBButton;
@property (nonatomic, strong) IBOutlet UIButton *RYBButton;

@property (nonatomic, strong) IBOutlet UIButton *DoneButton;
@property (nonatomic, strong) IBOutlet UIButton *RestoreButton;

- (IBAction)tappedCMYK:(id)sender;
- (IBAction)tappedRGB:(id)sender;
- (IBAction)tappedRYB:(id)sender;

- (IBAction)tappedRestore:(id)sender;
- (IBAction)tappedDone:(id)sender;

@end
