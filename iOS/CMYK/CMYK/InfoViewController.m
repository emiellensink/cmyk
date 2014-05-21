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
    // TODO: Change text on buttons depending on purchases
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

- (NSString *)getGameMode
{
	NSString *gameMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorSet"];
	if (!gameMode) gameMode = @"CMYK";

	return gameMode;
}

- (void)setGameMode:(NSString *)gameMode
{
	[[NSUserDefaults standardUserDefaults] setObject:gameMode forKey:@"colorSet"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadBecauseOfColorsetChangeNotification" object:nil];
	
	[self tappedDone:nil];
}

- (IBAction)tappedCMYK:(id)sender
{
	if ([[self getGameMode] isEqualToString:@"CMYK"]) return;
	
	[self setGameMode:@"CMYK"];

}

- (IBAction)tappedRGB:(id)sender
{
	if ([[self getGameMode] isEqualToString:@"RGB"]) return;
	
	// TODO: Check if purchased
	[self setGameMode:@"RGB"];
	
}

- (IBAction)tappedRYB:(id)sender
{
	if ([[self getGameMode] isEqualToString:@"RYB"]) return;

	// TODO: Check if purchased
	[self setGameMode:@"RYB"];
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
