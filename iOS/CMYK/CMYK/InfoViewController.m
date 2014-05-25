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

@property (nonatomic, strong) SKProduct *RGBProduct;
@property (nonatomic, strong) SKProduct *RYBProduct;

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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseComplete) name:@"purchaseComplete" object:nil];
	
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
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"purchasedRGB"])
		[self setGameMode:@"RGB"];
	else
	{
		NSLog(@"Can make payments: %d", [SKPaymentQueue canMakePayments]);
		SKPayment *buy = [SKPayment paymentWithProduct:self.RGBProduct];
		[[SKPaymentQueue defaultQueue] addPayment:buy];
	}
}

- (IBAction)tappedRYB:(id)sender
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"purchasedRYB"])
		[self setGameMode:@"RYB"];
	else
	{
		SKPayment *buy = [SKPayment paymentWithProduct:self.RYBProduct];
		[[SKPaymentQueue defaultQueue] addPayment:buy];
	}
}

- (IBAction)tappedRestore:(id)sender
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
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
		if ([obj.productIdentifier isEqualToString:@"CMYK_RGB"] && ![[NSUserDefaults standardUserDefaults] objectForKey:@"purchasedRGB"])
		{
			self.RGBButton.enabled = YES;
			NSString *text = [self.RGBButton currentTitle];
			
			NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
			[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
			[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
			[numberFormatter setLocale:obj.priceLocale];
			NSString *formattedString = [numberFormatter stringFromNumber:obj.price];
			
			text = [text stringByAppendingString:[NSString stringWithFormat:@" (%@)", formattedString]];
			
			[self.RGBButton setTitle:text forState:UIControlStateNormal];
			self.RGBProduct = obj;
		}
			
		if ([obj.productIdentifier isEqualToString:@"CMYK_RYB"] && ![[NSUserDefaults standardUserDefaults] objectForKey:@"purchasedRYB"])
		{
			self.RYBButton.enabled = YES;
			NSString *text = [self.RYBButton currentTitle];
			
			NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
			[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
			[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
			[numberFormatter setLocale:obj.priceLocale];
			NSString *formattedString = [numberFormatter stringFromNumber:obj.price];
			
			text = [text stringByAppendingString:[NSString stringWithFormat:@" (%@)", formattedString]];
			
			[self.RYBButton setTitle:text forState:UIControlStateNormal];
			self.RYBProduct = obj;
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

- (void)purchaseComplete
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"purchasedRGB"])
		[self.RGBButton setTitle:@"  Red Green Blue" forState:UIControlStateNormal];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"purchasedRYB"])
		[self.RYBButton setTitle:@"  Red Yellow Blue" forState:UIControlStateNormal];
}

@end
