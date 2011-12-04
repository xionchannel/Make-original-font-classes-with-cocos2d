//
//  MainLayer.m
//
//  Created by xionchannel software on 11/07/19.
//  Copyright 2011 xionchannel software. All rights reserved.
//

#import "MainLayer.h"

@implementation MainLayer

+(CCScene*) scene {
	CCScene *scene = [CCScene node];
	MainLayer *layer = [MainLayer node];
	[scene addChild:layer];
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		[self setIsTouchEnabled:YES];
		
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		//等幅文字を追加
		{
			emFont *f;
			f = [emFont fontWithText:@"FIXED FONT, TOUCH ME."];
			[f setCentering:ccp(size.width/2,size.height/2+48)];
			[self addChild:f];
			textFixed = f;
		}
		
		//プロポーショナル文字を追加
		{
			emFontProportional *f;
			f = [emFontProportional fontWithText:@"<S>Proportional Font!</><P>プロポーショナルフォント!"];
			[f setCentering:ccp(size.width/2,size.height/2-16)];
			[self addChild:f];
		}
		{
			emFontProportional *f;
			f = [emFontProportional fontWithText:@"タッチ　シテミテ　ヨ!"];
			[f setCentering:ccp(size.width/2,size.height/2-96)];
			[self addChild:f];
			textProportional = f;
		}
	}
	return self;
}

// タッチイベントを受け取ったときの処理
- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//タッチイベントを受け取ったら
	for (UITouch *myTouch in touches) {
		CGPoint uiViewPos = [myTouch locationInView:[myTouch view]];
		CGPoint cocosPos = [[CCDirector sharedDirector] convertToGL:uiViewPos];
		cocosPos = ccpSub(cocosPos, self.position);	//スクロール分だけ座標をずらして判定する
		
		if ([textFixed isHitByPosition:cocosPos]) {
			static BOOL flag = NO;
			if (!flag) {
				[textFixed setColor:ccYELLOW];
				flag = YES;
			}
			else {
				[textFixed setColor:ccWHITE];
				flag = NO;
			}
			return YES;
		}

		if ([textProportional isHitByPosition:cocosPos]) {
			id act1 = [CCMoveBy actionWithDuration:0.05f position:ccp(0,32)];
			id act2 = [CCMoveBy actionWithDuration:0.1f position:ccp(0,-48)];
			id act3 = [CCMoveBy actionWithDuration:0.05f position:ccp(0,16)];
			[textProportional runAction:[CCSequence actions:act1,act2,act3,nil]];
			return YES;
		}
	}
	return YES;
}

@end
