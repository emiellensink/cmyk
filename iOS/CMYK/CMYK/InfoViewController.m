//
//  InfoViewController.m
//  CMYK
//
//  Created by Emiel Lensink on 02/05/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)tappedCMYK:(id)sender
{
	
}

- (IBAction)tappedRGB:(id)sender
{
	
}

- (IBAction)tappedRYB:(id)sender
{
	
}

- (IBAction)tappedRestore:(id)sender
{
	
}

- (IBAction)tappedDone:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:^{
		
	}];
}

@end
