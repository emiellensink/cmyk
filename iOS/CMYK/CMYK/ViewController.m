//
//  ViewController.m
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "ViewController.h"

#import <GameKit/GameKit.h>

#import "QX3D/QX3DEngine.h"
#import "Implementation/CMYKScene.h"

@interface ViewController () <GKGameCenterControllerDelegate>
{
	BOOL trackFromButton;
	NSUInteger trackButtonIndex;
	
	GKPlayer *localPlayer;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) QX3DEngine *engine;

@property (strong, nonatomic) GKLocalPlayer *player;
@property (assign, nonatomic) BOOL playerAuthenticated;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context)
	{
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
	self.preferredFramesPerSecond = 60;
    
	self.engine = [QX3DEngine engineWithScene:[CMYKScene new]];
	CMYKScene *scene = (CMYKScene *)self.engine.scene;
	scene.delegate = self;
	
    [self setupGL];
	
	self.player = [GKLocalPlayer localPlayer];
	__weak GKLocalPlayer *weakPlayer = self.player;
	__weak typeof(self) weakSelf = self;
	
	self.player.authenticateHandler = ^(UIViewController *viewController, NSError *error)
	{
		if (viewController != nil)
		{
			//scene.isOccupiedBySomethingElse = YES;
			[weakSelf presentViewController:viewController animated:YES completion:^{
				
			}];
		}
		else if (weakPlayer.isAuthenticated)
		{
			weakSelf.playerAuthenticated = YES;
			
//			[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *achievementerror) {
//				NSLog(@"Achievements: %@", achievements);
//			}];
		}
		else
		{
			// Disable game center
		}
	};
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context)
        [EAGLContext setCurrentContext:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil))
	{
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
	
	[self.engine setupGLWithSize:self.view.frame.size];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];

	[self.engine cleanupGL];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
	[self.engine updateWithView:self.view interval:self.timeSinceLastUpdate];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	[self.engine renderInView:self.view rect:rect];
}

#pragma mark Prototype UI and gameplay

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *buttons = @[self.b1, self.b2, self.b3, self.b4];
	
	CGPoint loc = [[touches anyObject] locationInView:self.view];

	[buttons enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop)
	{
		if (CGRectContainsPoint(obj.frame, loc))
		{
			self->trackFromButton = YES;
			self->trackButtonIndex = idx;
		}
	}];
	
	CMYKScene *scene = (CMYKScene *)self.engine.scene;
	if (trackFromButton)[scene beginTrackingFromButton:trackButtonIndex withFrameSize:self.view.frame.size position:loc];
	else
		[scene beginTrackingWithFrameSize:self.view.frame.size position:loc];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint loc = [[touches anyObject] locationInView:self.view];

	CMYKScene *scene = (CMYKScene *)self.engine.scene;
	[scene moveTrackingWithFrameSize:self.view.frame.size position:loc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint loc = [[touches anyObject] locationInView:self.view];
	
	CMYKScene *scene = (CMYKScene *)self.engine.scene;
	[scene endTrackingWithFrameSize:self.view.frame.size position:loc];
	
	trackFromButton = NO;
	trackButtonIndex = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	CMYKScene *scene = (CMYKScene *)self.engine.scene;
	[scene cancelTracking];
	
	trackFromButton = NO;
	trackButtonIndex = 0;
}

#pragma mark CMYK scene delegate

- (void)becomeIdle
{
	if (self.preferredFramesPerSecond != 10)
	{
		NSLog(@"Became idle");
		self.preferredFramesPerSecond = 10;
	}
}

- (void)becomeActive
{
	if (self.preferredFramesPerSecond != 60)
	{
		NSLog(@"Became active");
		self.preferredFramesPerSecond = 60;
	}
}

- (void)gameCompletedWithScore:(NSUInteger)score
{
	if (self.playerAuthenticated)
	{
		[self.player loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
			if (!error)
			{
				GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardIdentifier];
				scoreReporter.value = score;
				
				[GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError *reporterror) {
					NSLog(@"Score sent.");
				}];
			}
		}];
	}
}

- (void)achievementObtained:(enum CMYKAchievements)achievement
{
	NSString *identifier;
	
	switch(achievement)
	{
		case CleanSlate:
			identifier = @"CMYK_CleanSlate";
			break;
		case Equal:
			identifier = @"CMYK_Equal";
			break;
		case Played100:
			identifier = @"CMYK_100";
			break;
		case Played250:
			identifier = @"CMYK_250";
			break;
		case Played500:
			identifier = @"CMYK_500";
			break;
	}
	
	if (self.playerAuthenticated)
	{
		GKAchievement *theAchievement = [[GKAchievement alloc] initWithIdentifier:identifier];
		if (theAchievement)
		{
			theAchievement.percentComplete = 100;
			theAchievement.showsCompletionBanner = YES;
			
			NSLog(@"Reporting achievement %@", theAchievement);
			
			[GKAchievement reportAchievements:@[theAchievement] withCompletionHandler:^(NSError *error) {
				if (error)
				{
					NSLog(@"Error in reporting achievements: %@", error);
				}
			}];
		}
	}
}

#pragma mark UI

- (IBAction)restartTapped:(id)sender
{
	CMYKScene *scene = (CMYKScene *)self.engine.scene;
	[scene restartGame];
}

- (IBAction)gameCenterTapped:(id)sender
{
	if (self.playerAuthenticated)
	{
		GKGameCenterViewController *vc = [[GKGameCenterViewController alloc] init];
		vc.gameCenterDelegate = self;

		CMYKScene *scene = (CMYKScene *)self.engine.scene;
		scene.isOccupiedBySomethingElse = YES;
		
		[self presentViewController:vc animated:YES completion:^{
			
		}];
	}
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
	[gameCenterViewController dismissViewControllerAnimated:YES completion:^{
		CMYKScene *scene = (CMYKScene *)self.engine.scene;
		scene.isOccupiedBySomethingElse = NO;
	}];
}

@end
