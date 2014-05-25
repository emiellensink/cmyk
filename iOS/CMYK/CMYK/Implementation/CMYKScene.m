//
//  CMYKScene.m
//  CMYK
//
//  Created by Emiel Lensink on 08/04/14.
//  Copyright (c) 2014 Emiel Lensink. All rights reserved.
//

#import "CMYKScene.h"

#import <GLKit/GLKit.h>

#import "../QX3D/QX3DObject.h"
#import "../QX3D/QX3DMaterial.h"

#import "CMYKRenderableSquare.h"
#import "CMYKRotationAnimator.h"
#import "CMYKWaveAnimator.h"
#import "CMYKFadeFromWhiteAnimator.h"
#import "CMYKDarkenAnimator.h"
#import "CMYKRenderableDigit.h"

#import "CMYKTileStack.h"
#import "CMYKTetromino.h"

#import "CMYKRenderableTexturedSquare.h"

#define PI 3.141592654

typedef struct tileArray
{
	char data[5][5];
} tileArray;

@interface CMYKScene ()
{
	CMYKTileStack *tiles[5][5];
	CMYKTetromino *tetromino;
	
	QX3DObject *scale;
	
	CGSize size;
	
	GLKTextureInfo *tetrominoTextures[7];
	GLKTextureInfo *colorCircles[3];
	
	NSArray *digitTextures;
	
	QX3DObject *sources[4];
	CMYKRenderableTexturedSquare *sourceCircleMaterials[4];
	CMYKRenderableTexturedSquare *sourceTetrominoMaterials[4];
	NSUInteger sourcerotations[4];
	NSUInteger sourcecolors[4];
	NSUInteger sourcetetrominos[4];
	
	BOOL trackingFromButton;
	NSUInteger trackingButtonIndex;
	
	CGPoint startPoint;
	
	GLfloat rotation;
	GLfloat targetRotation;
	GLfloat rotationDirection;
	
	GLfloat buttonY[4];
	GLfloat buttonTargetY[4];
	
	BOOL finalizingRotation;
	
	QX3DMaterial *flatmat;
	QX3DMaterial *colormat;
	QX3DMaterial *texturemat;
	
	NSTimeInterval idleTimer;
	NSTimeInterval dragTimer;
	NSTimeInterval timeLeftTimer;
	
	NSInteger blockcount;
	NSInteger score;
	
	BOOL gameOverState;
	BOOL playingIntroState;
	
	QX3DObject *darkOverlay;
	
	CMYKRenderableDigit *digits[3];
	CMYKRenderableDigit *scoreDigits[5];
	
	QX3DObject *outoftime;
	QX3DObject *outofmoves;
	QX3DObject *gameoverDisplay;
}

@end

@implementation CMYKScene

- (instancetype)init
{
    self = [super init];
    if (self)
	{
		self.baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadBecauseOfColorsetChangeNotification) name:@"reloadBecauseOfColorsetChangeNotification" object:nil];
		
    }
    return self;
}

- (void)reloadBecauseOfColorsetChangeNotification
{
	[self initializeWithSize:size];
}

- (void)updateWithSize:(CGSize)_size interval:(NSTimeInterval)timeSinceLastUpdate
{
	size = _size;
	idleTimer += timeSinceLastUpdate;
	dragTimer += timeSinceLastUpdate;
	if (!self.isOccupiedBySomethingElse) timeLeftTimer -= timeSinceLastUpdate;
	if (timeLeftTimer < 0 && !gameOverState)
	{
		idleTimer = 0;
		gameoverDisplay = outoftime;
		[gameoverDisplay attachToObject:self];
		[self.delegate becomeActive];
		[self gameOver];
	}

	if (idleTimer > 1.0) [self.delegate becomeIdle];
	
	float rangeX = size.width / 2.0;
	float rangeY = size.height / 2.0;
    self.projectionMatrix = GLKMatrix4MakeOrtho(-rangeX, rangeX, -rangeY, rangeY, -100, 100);

	scale.scale = rangeX / 3.0;
	tetromino.scale = rangeX / 3.0;
	
	if (targetRotation > rotation) rotation += ((targetRotation - rotation) / 5.0);
	if (targetRotation < rotation) rotation -= ((rotation - targetRotation) / 5.0);
	
	if (finalizingRotation && fabs(targetRotation - rotation) < 0.01)
	{
		[self normalizeRotationWithTarget:targetRotation];
		
		rotation = 0;
		targetRotation = 0;
		finalizingRotation = NO;
	}
	
	scale.orientation = GLKQuaternionMakeWithAngleAndAxis(rotation, 0, 0, 1);
	
	for (NSInteger i = 0; i < 4; i++)
	{
		if (buttonTargetY[i] > buttonY[i]) buttonY[i] += ((buttonTargetY[i] - buttonY[i]) / 7.0);
		if (buttonTargetY[i] < buttonY[i]) buttonY[i] -= ((buttonY[i] - buttonTargetY[i]) / 7.0);
		
		sources[i].position = GLKVector3Make(sources[i].position.x, buttonY[i], 0);
	}
	
	{
		if (timeLeftTimer < 0) timeLeftTimer = 0;
		
		NSInteger left = (NSInteger)timeLeftTimer;
		for (int i = 0; i < 3; i++)
		{
			NSInteger d = left % 10;
			left /= 10;
			
			[digits[2 - i] switchToDigit:d];
		}
	}
	
	{
		NSInteger left = (NSInteger)score;
		for (int i = 0; i < 5; i++)
		{
			NSInteger d = left % 10;
			left /= 10;
			
			[scoreDigits[4 - i] switchToDigit:d animated:YES];
		}
	}
	
	[super updateWithSize:size interval:timeSinceLastUpdate];
}

- (tileArray)rotateLeft:(tileArray)input
{
	tileArray res;
	
	// rotate left
	for (NSInteger x = 0; x < 5; x++)
	{
		for (NSInteger y = 0; y < 5; y++)
		{
			res.data[y][4 - x] = input.data[x][y];
		}
	}

	return res;
}

- (tileArray)rotateRight:(tileArray)input
{
	tileArray res;
	
	// rotate right
	for (NSInteger x = 0; x < 5; x++)
	{
		for (NSInteger y = 0; y < 5; y++)
		{
			res.data[4 - y][x] = input.data[x][y];
		}
	}
	
	return res;
}

- (tileArray)rotateTwice:(tileArray)input
{
	tileArray res;
	
	// rotate left twice
	for (NSInteger x = 0; x < 5; x++)
	{
		for (NSInteger y = 0; y < 5; y++)
		{
			res.data[4 - x][4 - y] = input.data[x][y];
		}
	}

	return res;
}

- (tileArray)rotateNone:(tileArray)input
{
	return input;
}

- (tileArray)tilesToTileArray
{
	tileArray res;

	for (NSInteger x = 0; x < 5; x++)
	{
		for (NSInteger y = 0; y < 5; y++)
		{
			char l1 = tiles[x][y].l1 ? 1 : 0;
			char l2 = tiles[x][y].l2 ? 1 : 0;
			char l3 = tiles[x][y].l3 ? 1 : 0;
			char t = l1 | (l2 << 1) | (l3 << 2);
			
			res.data[x][y] = t;
		}
	}
	
	return res;
}

- (void)tileArrayToTiles:(tileArray)input
{
	for (NSInteger x = 0; x < 5; x++)
	{
		for (NSInteger y = 0; y < 5; y++)
		{
			char l1 = input.data[x][y] & 1;
			char l2 = input.data[x][y] & (1 << 1);
			char l3 = input.data[x][y] & (1 << 2);
			
			tiles[x][y].l1 = l1;
			tiles[x][y].l2 = l2;
			tiles[x][y].l3 = l3;
		}
	}
}

- (void)normalizeRotationWithTarget:(GLfloat)target
{
	tileArray temp;
	tileArray res;
	
	temp = [self tilesToTileArray];

	if (target < -0.25 * PI && target > -0.75 * PI) res = [self rotateRight:temp];
	if (target > 0.25 * PI && target < 0.75 * PI) res = [self rotateLeft:temp];
	if (target >= -0.25 * PI && target <= 0.25 * PI) res = [self rotateNone:temp];
	if (target <= -0.75 * PI || target >= 0.75 * PI) res = [self rotateTwice:temp];
	
	[self tileArrayToTiles:res];
}

- (BOOL)tetrominoFitsAtPosition:(CGPoint)pos withTileArray:(tileArray)array
{
	BOOL res = YES;
	
	for (NSInteger i = 0; i < tetromino.dotCount; i++)
	{
		CGPoint p = [tetromino dotAtIndex:i];
		NSInteger c = tetromino.color;
		
		char x = array.data[(int)pos.x + (int)p.x][(int)pos.y + (int)p.y];
		
		char l1 = x & 1;
		char l2 = x & (1 << 1);
		char l3 = x & (1 << 2);
		
		if (c == 0 && l1) res = NO;
		if (c == 1 && l2) res = NO;
		if (c == 2 && l3) res = NO;
	}

	return res;
}

- (BOOL)checkGameOver
{
	// OK, this is a bit inefficient, but since no animations are running,
	//  we can get away with it...
	
	tileArray now = [self tilesToTileArray];
	
	BOOL allowed = NO;
	
	for (int z = 0; z < 4; z++)
	{
		now = [self rotateLeft:now];
		
		for (int i = 0; i < 4; i++)
		{
			[tetromino prepareWithTetromino:sourcetetrominos[i]];
			[tetromino setColor:sourcecolors[i]];

			for (int x = 0; x < 5 - tetromino.width; x++)
			{
				for (int y = 0; y < 5 - tetromino.height; y++)
				{
					if ([self tetrominoFitsAtPosition:CGPointMake(x, y) withTileArray:now])
						allowed = YES;
				}
			}
		}
	}

	return !allowed;
}

- (void)gameOver
{
	gameOverState = YES;

	for (NSInteger i = 0; i < 4; i++)
	{
		//buttonTargetY[i] = (-size.height / 2.0) - 100.0;
	}
	
	[self.delegate gameCompletedWithScore:score];
	
	QX3DObject *obj = [QX3DObject new];
	
	CMYKRenderableSquare *sq = [CMYKRenderableSquare renderableForObject:obj];
	sq.material = flatmat;
	CMYKDarkenAnimator *anim = [CMYKDarkenAnimator animatorForObject:obj];
	[anim attachToObject:obj];	// A bit redundant...
	
	obj.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
	obj.position = GLKVector3Make(0, 0, 0);
	obj.scale = 6.0;
	
	[obj attachToObject:scale];
	darkOverlay = obj;
	
	[tetromino detach];
}

- (void)restartGame
{
	idleTimer = 0;
	[self.delegate becomeActive];

	[self performSelector:@selector(restartGameImpl) withObject:nil afterDelay:0.3];
}

- (void)restartGameImpl
{
	if (darkOverlay) [darkOverlay detach];
	darkOverlay = nil;
	
	idleTimer = 0;
	score = 0;
	blockcount = 0;
	timeLeftTimer = 60;
	
	if (gameoverDisplay)
	{
		[gameoverDisplay detach];
		gameoverDisplay = nil;
	}
	
	CGPoint p;
	
	for (NSInteger x = 0; x < 5; x++)
	{
		for (NSInteger y = 0; y < 5; y++)
		{
			p.x = x; p.y = y;
			p.x -= 2; p.y -= 2;
			p.x *= 1.1; p.y *= 1.1;
			
			QX3DObject *obj = [QX3DObject new];
			CMYKRenderableSquare *sq = [CMYKRenderableSquare renderableForObject:obj];
			sq.material = flatmat;
			CMYKFadeFromWhiteAnimator *anim = [CMYKFadeFromWhiteAnimator animatorForObject:obj];
			[anim attachToObject:obj];	// A bit redundant...
			
			obj.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
			obj.position = GLKVector3Make(p.x, -p.y, 0);
			
			[obj attachToObject:scale];

			tiles[x][y].l1 = NO;
			tiles[x][y].l2 = NO;
			tiles[x][y].l3 = NO;
		}
	}
	
	for (NSInteger i = 0; i < 4; i++)
	{
		// Initialize button with new values
		NSInteger random3 = arc4random() % 3;
		NSInteger random7 = arc4random() % 7;
		
		sourceCircleMaterials[i].glkTexture = colorCircles[i < 3 ? i : random3];
		sourcecolors[i] = i < 3 ? i : random3;
		
		sourceTetrominoMaterials[i].glkTexture = tetrominoTextures[random7];
		sourcetetrominos[i] = random7;
		
		buttonTargetY[i] = (-size.height / 2.0) + 40.0;
	}
	
	[tetromino detach];
	gameOverState = NO;
}

- (void)prepareForRendering
{
	[super prepareForRendering];
	
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

- (void)initializeWithSize:(CGSize)newSize
{
	// Remove all old objects, so we can re-initialize the scene should something important happen...
	{
		NSMutableArray *allObjects = [NSMutableArray array];
		
		[self.objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[allObjects addObject:obj];
		}];
		
		[allObjects enumerateObjectsUsingBlock:^(QX3DObject *obj, NSUInteger idx, BOOL *stop) {
			[obj detach];
		}];
	}

	size = newSize;
	
	for (int i = 0; i < 7; i++)
	{
		NSString *name = [NSString stringWithFormat:@"tetromino%d@2x", i];
		
		NSError *err;
		
		NSString *texPath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
		tetrominoTextures[i] = [GLKTextureLoader textureWithContentsOfFile:texPath options:@{GLKTextureLoaderOriginBottomLeft: @(YES)} error:&err];
	}
	
	{
		NSMutableArray *arr = [NSMutableArray array];
		
		for (int i = 0; i < 10; i++)
		{
			NSString *name = [NSString stringWithFormat:@"score_%d@2x", i];

			NSError *err;
			
			NSString *texPath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
			[arr addObject:[GLKTextureLoader textureWithContentsOfFile:texPath options:@{GLKTextureLoaderOriginBottomLeft: @(YES)} error:&err]];
		}

		digitTextures = [NSArray arrayWithArray:arr];
	}
	
	NSString *gameMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"colorSet"];
	if (!gameMode) gameMode = @"CMYK";
		
	NSArray *arr;
	if ([gameMode isEqualToString:@"CMYK"]) arr = @[@"cyan_circle@2x", @"magenta_circle@2x", @"yellow_circle@2x"];
	if ([gameMode isEqualToString:@"RGB"]) arr = @[@"red_circle@2x", @"green_circle@2x", @"blue_circle@2x"];
	if ([gameMode isEqualToString:@"RYB"]) arr = @[@"red_circle@2x", @"yellow_circle@2x", @"blue_circle@2x"];
	
	[arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSError *err;
		
		NSString *texPath = [[NSBundle mainBundle] pathForResource:obj ofType:@"png"];
		self->colorCircles[idx] = [GLKTextureLoader textureWithContentsOfFile:texPath options:@{GLKTextureLoaderOriginBottomLeft: @(YES)} error:&err];
	}];
	
	NSString *pixelProgram;
	if ([gameMode isEqualToString:@"CMYK"]) pixelProgram = @"subtractive";
	if ([gameMode isEqualToString:@"RGB"]) pixelProgram = @"additive";
	if ([gameMode isEqualToString:@"RYB"]) pixelProgram = @"paint";
		
	colormat = [QX3DMaterial materialWithVertexProgram:@"simplevertex" pixelProgram:pixelProgram attributes:@{@"position": @(GLKVertexAttribPosition)}];
	
	texturemat = [QX3DMaterial materialWithVertexProgram:@"texturedvertex" pixelProgram:@"textured" attributes:@{@"position": @(GLKVertexAttribPosition), @"texturecoordinate": @(GLKVertexAttribTexCoord0)}];

	flatmat = [QX3DMaterial materialWithVertexProgram:@"simplevertex" pixelProgram:@"flatcolor" attributes:@{@"position": @(GLKVertexAttribPosition)}];
		
	scale = [QX3DObject new];
	scale.orientation = GLKQuaternionMakeWithAngleAndAxis(rotation, 0, 0, 1);
	scale.position = GLKVector3Make(0, 0, 0);
	[scale attachToObject:self];
	
	for (int x = -2; x <= 2; x++)
	{
		for (int y = -2; y <= 2; y++)
		{
			QX3DObject *obj = [QX3DObject new];
			obj.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
			obj.position = GLKVector3Make(x * 1.1, -y * 1.1, 0);
			
			CMYKRenderableSquare *square = [CMYKRenderableSquare renderableForObject:obj];
			square.color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
			
			square.material = flatmat;
			[obj attachToObject:scale];
			
			CMYKTileStack *stack = [[CMYKTileStack alloc] initWithMaterial:colormat];
			stack.position = GLKVector3Make(x * 1.1, -y * 1.1, 0);

			[stack attachToObject:scale];
			
			tiles[x + 2][y + 2] = stack;
		}
	}

	tetromino = [[CMYKTetromino alloc] initWithMaterial:colormat];
	[tetromino setRotation:0];
	
	for (NSInteger i = 0; i < 4; i++)
	{
		QX3DObject *obj = [QX3DObject new];
		obj.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
		obj.position = GLKVector3Make(-111 + (i * 74), -500, 0);
		sources[i] = obj;
		
		buttonY[i] = -500;
		buttonTargetY[i] = (-size.height / 2.0) + 40.0;
		
		NSInteger random3 = arc4random() % 3;
		NSInteger random7 = arc4random() % 7;
		
		CMYKRenderableTexturedSquare *s = [CMYKRenderableTexturedSquare renderableForObject:obj];
		s.material = texturemat;
		s.glkTexture = colorCircles[i < 3 ? i : random3];
		sourceCircleMaterials[i] = s;
		sourcecolors[i] = i < 3 ? i : random3;
		
		CMYKRenderableTexturedSquare *t = [CMYKRenderableTexturedSquare renderableForObject:obj];
		t.material = texturemat;
		t.glkTexture = tetrominoTextures[random7];
		sourceTetrominoMaterials[i] = t;
		sourcetetrominos[i] = random7;
		
		[obj attachToObject:self];
	}
	
	for (NSInteger i = 0; i < 3; i++)
	{
		QX3DObject *obj = [QX3DObject new];
		obj.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
		obj.position = GLKVector3Make(10 + i * 14, (size.height / 2.0) - 40, 0);
		
		CMYKRenderableDigit *digit = [CMYKRenderableDigit renderableForObject:obj];
		digit.material = texturemat;
		[digit setDigitTextures:digitTextures];
		[digit switchToDigit:0];
		
		digits[i] = digit;
		
		[obj attachToObject:self];
	}

	for (NSInteger i = 0; i < 5; i++)
	{
		QX3DObject *obj = [QX3DObject new];
		obj.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
		obj.position = GLKVector3Make(-90 + i * 14, (size.height / 2.0) - 40, 0);
		
		CMYKRenderableDigit *digit = [CMYKRenderableDigit renderableForObject:obj];
		digit.material = texturemat;
		[digit setDigitTextures:digitTextures];
		[digit switchToDigit:0];
		
		scoreDigits[i] = digit;
		
		[obj attachToObject:self];
	}
	
	{
		QX3DObject *obj = [QX3DObject new];
		obj.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
		obj.position = GLKVector3Make(-10, (size.height / 2.0) - 40, 0);
		
		CMYKRenderableTexturedSquare *clock = [CMYKRenderableTexturedSquare renderableForObject:obj];
		clock.material = texturemat;
		clock.texture = @"clock@2x";
		
		[obj attachToObject:self];
	}
	
	{
		outofmoves = [QX3DObject new];
		outofmoves.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
		outofmoves.position = GLKVector3Make(0, 0, 0);
		
		CMYKRenderableTexturedSquare *sq = [CMYKRenderableTexturedSquare renderableForObject:outofmoves];
		sq.material = texturemat;
		sq.texture = @"outofmoves@2x";
	}

	{
		outoftime = [QX3DObject new];
		outoftime.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
		outoftime.position = GLKVector3Make(0, 0, 0);
		
		CMYKRenderableTexturedSquare *sq = [CMYKRenderableTexturedSquare renderableForObject:outoftime];
		sq.material = texturemat;
		sq.texture = @"outoftime@2x";
	}
	
	timeLeftTimer = 60;
	
	[self restartGame];
}

- (void)moveTetrominoToPoint:(CGPoint)point
{
	float rangeX = size.width / 2.0;
	float rangeY = size.height / 2.0;
	
	CGFloat w = tetromino.width;
	CGFloat h = tetromino.height;
	CGFloat oscale = tetromino.scale;
	
	CGFloat offX = -(w / 2.0) * oscale;
	CGFloat offY = h * oscale + (oscale / 2.0);
		
	tetromino.position = GLKVector3Make(point.x - rangeX + offX, (size.height - point.y) - rangeY + offY, 0);
}

- (void)dropTetrominoIfAllowed
{
	NSInteger subscore = 0;
	
	GLfloat tileScale = scale.scale * 1.1;
	CGPoint topLeft = CGPointMake(size.width / 2.0 - 2.5 * tileScale, size.height / 2.0 - 2.5 * tileScale);
	
	CGPoint tetrominoTopLeft = CGPointMake(tetromino.position.x - tetromino.scale / 2.0, (-tetromino.position.y) - tetromino.scale / 2.0);
	tetrominoTopLeft.x = tetrominoTopLeft.x + size.width / 2.0;
	tetrominoTopLeft.y = tetrominoTopLeft.y + size.height / 2.0;
	
	CGFloat tX = (tetrominoTopLeft.x - topLeft.x) / tileScale;
	CGFloat tY = (tetrominoTopLeft.y - topLeft.y) / tileScale;
	
	NSInteger iX = roundf(tX);
	NSInteger iY = roundf(tY);
	
	// See if it fits
	BOOL allowed = YES;
	
	if (iX < 0 || iY < 0) allowed = NO;
	if (iX + tetromino.width > 4) allowed = NO;
	if (iY + tetromino.height > 4) allowed = NO;
	
	if (allowed)
		allowed = [self tetrominoFitsAtPosition:CGPointMake(iX, iY) withTileArray:[self tilesToTileArray]];
	
	if (allowed)
	{
		subscore += 100.0 / dragTimer;
		
		for (NSInteger i = 0; i < tetromino.dotCount; i++)
		{
			CGPoint p = [tetromino dotAtIndex:i];
			NSInteger c = tetromino.color;
			
			CMYKTileStack *t = tiles[(int)p.x + iX][(int)p.y + iY];
			
			if (c == 0) { t.l1 = YES; }
			if (c == 1) { t.l2 = YES; }
			if (c == 2) { t.l3 = YES; }
		}
		
		for (int x = 0; x < 5; x++)
		{
			for (int y = 0; y < 5; y++)
			{
				CMYKTileStack *stack = tiles[x][y];
				if (stack.l1 && stack.l2 && stack.l3)
				{
					stack.l1 = NO;
					stack.l2 = NO;
					stack.l3 = NO;
					
					subscore += 100.0;
				}
			}
		}
		
		// Create flash objects
		for (NSInteger i = 0; i < tetromino.dotCount; i++)
		{
			CGPoint p = [tetromino dotAtIndex:i];
			
			p.x += iX; p.y += iY;
			p.x -= 2; p.y -= 2;
			p.x *= 1.1; p.y *= 1.1;
			
			QX3DObject *obj = [QX3DObject new];
			CMYKRenderableSquare *sq = [CMYKRenderableSquare renderableForObject:obj];
			sq.material = flatmat;
			CMYKFadeFromWhiteAnimator *anim = [CMYKFadeFromWhiteAnimator animatorForObject:obj];
			[anim attachToObject:obj];	// A bit redundant...
			
			obj.orientation = GLKQuaternionMakeWithAngleAndAxis(0, 0, 0, 1);
			obj.position = GLKVector3Make(p.x, -p.y, 0);
			
			[obj attachToObject:scale];
		}
		
		// Initialize button with new values
		NSInteger random7 = arc4random() % 7;
		
		if (blockcount < 250)
		{
			NSInteger diff = 0;
			while(diff != 7)
			{
				NSInteger random3 = arc4random() % 3;
				sourceCircleMaterials[trackingButtonIndex].glkTexture = colorCircles[random3];
				sourcecolors[trackingButtonIndex] = random3;
			
				diff = 0;
				
				for (int i = 0; i < 4; i++)
					diff |= (1 << sourcecolors[i]);
			}
		}
		
		sourceTetrominoMaterials[trackingButtonIndex].glkTexture = tetrominoTextures[random7];
		sourcetetrominos[trackingButtonIndex] = random7;
		
		[tetromino detach];
		
		buttonTargetY[trackingButtonIndex] = (-size.height / 2.0) + 40.0;
		
		blockcount++;
		subscore += blockcount * 4.0;
		
		dragTimer = 0;
		timeLeftTimer += 5;
		
		score += subscore;
		NSLog(@"Score: %ld (%ld)", (long)score, (long)subscore);
		
		if (blockcount == 100)
			[self.delegate achievementObtained:Played100];
		if (blockcount == 250)
			[self.delegate achievementObtained:Played250];
		if (blockcount == 500)
			[self.delegate achievementObtained:Played500];

		{
			BOOL empty = YES;
			for (NSInteger x = 0; x < 5; x++)
			{
				for (NSInteger y = 0; y < 5; y++)
				{
					CMYKTileStack *t = tiles[x][y];
					
					if (t.l1 != 0 || t.l2 != 0 || t.l3 != 0) empty = NO;
				}
			}
			
			if (empty)
				[self.delegate achievementObtained:CleanSlate];
		}
		
		{
			BOOL tl1 = tiles[0][0].l1;
			BOOL tl2 = tiles[0][0].l2;
			BOOL tl3 = tiles[0][0].l3;
			
			BOOL same = YES;
			for (NSInteger x = 0; x < 5; x++)
			{
				for (NSInteger y = 0; y < 5; y++)
				{
					CMYKTileStack *t = tiles[x][y];
					
					if (t.l1 != tl1 || t.l2 != tl2 || t.l3 != tl3) same = NO;
				}
			}
			
			if (same)
				[self.delegate achievementObtained:Equal];
		}
	}
	else
	{
		[tetromino detach];
		buttonTargetY[trackingButtonIndex] = (-size.height / 2.0) + 40.0;
	}
}

- (void)beginTrackingFromButton:(NSUInteger)index withFrameSize:(CGSize)newSize position:(CGPoint)position
{
	if (!gameOverState)
	{
		idleTimer = 0;
		[self.delegate becomeActive];

		trackingFromButton = YES;
		trackingButtonIndex = index;
		
		[tetromino prepareWithTetromino:sourcetetrominos[trackingButtonIndex]];
		[tetromino setColor:sourcecolors[trackingButtonIndex]];
		[tetromino attachToObject:self];
		
		[self moveTetrominoToPoint:position];
			
		buttonTargetY[trackingButtonIndex] = (-size.height / 2.0) - 100.0;
	}
}

- (void)beginTrackingWithFrameSize:(CGSize)newSize position:(CGPoint)position
{
	if (!gameOverState)
	{
		idleTimer = 0;
		[self.delegate becomeActive];

		trackingFromButton = NO;
		startPoint = position;
	//	if (position.y > size.height / 2.0) rotationDirection = 1.0;
	//	else rotationDirection = -1.0;
	}
}
- (void)endTrackingWithFrameSize:(CGSize)newSize position:(CGPoint)position
{
	if (!gameOverState)
	{
		idleTimer = 0;
		[self.delegate becomeActive];

		if (!trackingFromButton)
		{
			if (!finalizingRotation)
			{
				if (targetRotation < -0.25 * PI && targetRotation > -0.75 * PI)
					targetRotation = -0.5 * PI;
				if (targetRotation > 0.25 * PI && targetRotation < 0.75 * PI)
					targetRotation = 0.5 * PI;
				if (targetRotation >= -0.25 * PI && targetRotation <= 0.25 * PI)
					targetRotation = 0;
				if (targetRotation <= -0.75 * PI) targetRotation = -PI;
				if (targetRotation >= 0.75 * PI) targetRotation = PI;
				
				finalizingRotation = YES;
				trackingFromButton = NO;
			}
		}
		else
		{
			{
				[self dropTetrominoIfAllowed];

				BOOL gameOver = [self checkGameOver];
				if (gameOver)
				{
					gameoverDisplay = outofmoves;
					[gameoverDisplay attachToObject:self];
					[self gameOver];
				}
			}
		}
	}
}

- (void)moveTrackingWithFrameSize:(CGSize)newSize position:(CGPoint)position
{
	if (!gameOverState)
	{
		idleTimer = 0;
		[self.delegate becomeActive];
		
		if (!trackingFromButton)
		{
			if (!finalizingRotation)
			{
				GLKVector3 v1 = GLKVector3Make(startPoint.x - (size.width / 2.0), startPoint.y - (size.height / 2.0), 0);
				GLKVector3 v2 = GLKVector3Make(position.x - (size.width / 2.0), position.y - (size.height / 2.0), 0);
				
				v1 = GLKVector3Normalize(v1);
				v2 = GLKVector3Normalize(v2);
				
				GLKVector3 v3 = GLKVector3CrossProduct(v1, v2);
				
				GLfloat dot = GLKVector3DotProduct(v1, v2);
				GLfloat f = acos(dot);
				GLfloat fac = v3.z > 0 ? -1.0 : 1.0;
				
				targetRotation = f * fac;
				rotation = f * fac;
			}
		}
		else
		{
			[self moveTetrominoToPoint:position];
		}
	}
}

- (void)cancelTracking
{
	if (!gameOverState)
	{
		idleTimer = 0;
		[self.delegate becomeActive];
		
		if (!trackingFromButton)
		{
			if (!finalizingRotation)
			{
				if (targetRotation < -0.25 * PI && targetRotation > -0.75 * PI)
					targetRotation = -0.5 * PI;
				if (targetRotation > 0.25 * PI && targetRotation < 0.75 * PI)
					targetRotation = 0.5 * PI;
				if (targetRotation >= -0.25 * PI && targetRotation <= 0.25 * PI)
					targetRotation = 0;
				if (targetRotation <= -0.75 * PI) targetRotation = -PI;
				if (targetRotation >= 0.75 * PI) targetRotation = PI;
				
				finalizingRotation = YES;
				trackingFromButton = NO;
			}
		}
		else
		{
			// Move button to original position...
			buttonTargetY[trackingButtonIndex] = (-size.height / 2.0) + 40.0;
		}
	}
}

@end
