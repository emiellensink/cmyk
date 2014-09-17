//
//  AppDelegate.m
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "AppDelegate.h"

@import StoreKit;

@interface AppDelegate () <SKPaymentTransactionObserver>
{
	
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark Store kit stuff

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	[transactions enumerateObjectsUsingBlock:^(SKPaymentTransaction *obj, NSUInteger idx, BOOL *stop) {
		
		if (obj.transactionState == SKPaymentTransactionStatePurchased || obj.transactionState == SKPaymentTransactionStateRestored)
		{
			if ([obj.payment.productIdentifier isEqualToString:@"CMYK_RGB"])
			{
				[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"purchasedRGB"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"purchaseComplete" object:nil];
			}

			if ([obj.payment.productIdentifier isEqualToString:@"CMYK_RYB"])
			{
				[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"purchasedRYB"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"purchaseComplete" object:nil];
			}
			
			[[SKPaymentQueue defaultQueue] finishTransaction:obj];
		}
	}];
}

@end
