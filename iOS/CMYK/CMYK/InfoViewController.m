//
//  InfoViewController.m
//  CMYK
//
//  Created by Emiel Lensink on 02/05/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "InfoViewController.h"
#import <StoreKit/StoreKit.h>

@interface InfoViewController () <SKProductsRequestDelegate>

@property (nonatomic, strong) SKProductsRequest *productsRequest;

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
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"purchasedRGB"])
		[self.RGBButton setTitle:@"  Red Green Blue" forState:UIControlStateNormal];
	else
		self.RGBButton.enabled = NO;

	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"purchasedRYB"])
		[self.RYBButton setTitle:@"  Red Yellow Blue" forState:UIControlStateNormal];
	else
		self.RYBButton.enabled = NO;
	
	NSSet *products = [NSSet setWithArray:@[@"CMYK_RGB", @"CMYK_RYB"]];
	self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:products];
	self.productsRequest.delegate = self;
	[self.productsRequest start];
	
	NSLog(@"Products request started");
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

#pragma mark Store Kit stuff

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	NSLog(@"%@ - %@", request, response);
	
	[response.products enumerateObjectsUsingBlock:^(SKProduct *obj, NSUInteger idx, BOOL *stop) {
		if ([obj.productIdentifier isEqualToString:@"CMYK_RGB"])
		{
			self.RGBButton.enabled = YES;
		}
			
		if ([obj.productIdentifier isEqualToString:@"CMYK_RYB"])
		{
			self.RGBButton.enabled = YES;
		}
	}];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	NSLog(@"Storekit error %@", error);
}

- (void)requestDidFinish:(SKRequest *)request
{
	NSLog(@"Storekit request did finish");
}

@end
