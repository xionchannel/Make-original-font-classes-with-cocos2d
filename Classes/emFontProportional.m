//
//  emFontProportional.m
//
//  Created by xionchannel software on 11/04/06.
//  Copyright 2011 xionchannel software. All rights reserved.
//

#import "emFontProportional.h"

#define CCCA(action)	[[action copy] autorelease]

@interface emFontProportional(private)
- (CCSprite*) __makeCharacterSpriteFrame:(CCSpriteFrame*)f 
								  string:(NSString*)c 
								position:(CGPoint*)pos 
								isShadow:(BOOL)isShadow;
- (NSString*) __correctString:(NSString*)string;
@end

@implementation emFontProportional

@synthesize characters, textColor, shadowColor, shadowOpacity, dakuten, chars;

- (void)_init {
	NSString * plistPath;
	
	plistPath = [[NSBundle mainBundle] pathForResource:@"fontProportional" ofType:@"plist"];
	self.characters = [NSDictionary dictionaryWithContentsOfFile:plistPath];

	plistPath = [[NSBundle mainBundle] pathForResource:@"dakuten" ofType:@"plist"];
	self.dakuten = [NSDictionary dictionaryWithContentsOfFile:plistPath];
	
	self.chars = [CCArray array];
}

- (void)dealloc {
	self.characters = nil;
	self.dakuten = nil;
	self.chars = nil;
	
	[super dealloc];
}

//テキストを指定して初期化
+ (id)fontWithText:(NSString*)string {
	emFontProportional *f = [emFontProportional node];
	[f _init];
	f.textColor = ccWHITE;
	f.shadowColor = ccBLACK;
	f.shadowOpacity = 255;
	[f setText:string];
	return f;
}

//テキストを指定して初期化
+ (id)fontWithText:(NSString*)string invert:(BOOL)inv {
	emFontProportional *f = [emFontProportional node];
	[f _init];
	if (inv) {
		f.textColor = ccBLACK;
		f.shadowColor = ccc3(200, 200, 200);
	}
	else {
		f.textColor = ccWHITE;
		f.shadowColor = ccBLACK;
	}
	f.shadowOpacity = 255;
	[f setText:string];
	return f;
}

//テキストを設定する
- (void)setText:(NSString *)string {
	[self setText:string color:self.textColor shadowColor:self.shadowColor shadowOpacity:self.shadowOpacity];
}
- (void)setText:(NSString*)string 
		  color:(ccColor3B)_color
	shadowColor:(ccColor3B)_shadowColor
  shadowOpacity:(int)_shadowOpacity
{
	self.textColor = _color;
	self.shadowColor = _shadowColor;
	self.shadowOpacity = _shadowOpacity;
	ccColor3B tempTextColor = _color;
	
	[self removeAllChildrenWithCleanup:YES];
	CCSprite *s;
	CCARRAY_FOREACH(self.chars, s) {
		[s removeFromParentAndCleanup:YES];
	}
	[chars removeAllObjects];
	
	string = [self __correctString:string];	
	int tcount = string.length;
	if (tcount==0) return;
	
	CGPoint pos = ccp(0,0);
	for (int i=0; i<tcount; i++) {
		NSString *c = [string substringWithRange:NSMakeRange(i, 1)];
		if (![c compare:@" "]) {	//半角スペース
			pos.x+=4*2;
		}
		else if (![c compare:@"　"]) {	//全角スペース
			pos.x+=5*2;
		}
		else if (![c compare:@"<"]) {
			//まずデフォルトカラーに戻る
			self.textColor = tempTextColor;
			
			//制御命令の解析
			for (int j=i; j<tcount; j++) {
				c = [string substringWithRange:NSMakeRange(j, 1)];
				if (![c compare:@">"]) {
					i=j;
					break;
				}
				else if (![c compare:@"R"]) {
					//赤
					self.textColor = ccRED;
				}
				else if (![c compare:@"Y"]) {
					//黄
					self.textColor = ccYELLOW;
				}
				else if (![c compare:@"B"]) {
					//青
					self.textColor = ccBLUE;
				}
				else if (![c compare:@"S"]) {
					//水色
					self.textColor = ccc3(0, 255, 255);
				}
				else if (![c compare:@"P"]) {
					//ピンク
					self.textColor = ccc3(255, 120, 190);
				}
				else if (![c compare:@"G"]) {
					//緑
					self.textColor = ccc3(0, 180, 0);
				}
				else if (![c compare:@"O"]) {
					//オレンジ
					self.textColor = ccORANGE;
				}
				else if (![c compare:@"H"]) {
					//灰色
					self.textColor = ccGRAY;
				}
				else if (![c compare:@"/"]) {
					//改行
					pos = ccp(0, pos.y-32);
				}
			}
		}
		else {
			if (shadowOpacity>0) {
				//影追加
				CCSpriteFrame *f = [self getFrameWithString:c isShadow:YES];
				CCSprite *s = [self __makeCharacterSpriteFrame:f string:c position:&pos isShadow:YES];
				s.color = self.shadowColor;
				s.opacity = self.shadowOpacity;
				[self addChild:s];
				[chars addObject:s];
			}
			CCSpriteFrame *f = [self getFrameWithString:c isShadow:NO];
			CCSprite *s = [self __makeCharacterSpriteFrame:f string:c position:&pos isShadow:NO];
			s.color = self.textColor;
			[self addChild:s];
			[chars addObject:s];
		}
	}
}
//文字スプライトの初期化(private)
- (CCSprite*) __makeCharacterSpriteFrame:(CCSpriteFrame*)f 
								 string:(NSString*)c 
							   position:(CGPoint*)pos 
							   isShadow:(BOOL)isShadow
{
	CCSprite *s = [CCSprite spriteWithSpriteFrame:f];
	[s.texture setAliasTexParameters];
	s.anchorPoint = ccp(0,0);
	s.scale = 2.0f;
	if (![c compare:@"゛"] || ![c compare:@"゜"]) {	//濁点・半濁点
		s.position = ccp(pos->x -4*2, pos->y +8*2);
	}
	else {
		s.position = *pos;
		if (!isShadow) pos->x += s.contentSize.width*2;
	}
	return s;
}

//カタカナの濁点等を分解する(private)
- (NSString*) __correctString:(NSString*)string {
	NSMutableString *ret = [NSMutableString string];
	for (int i=0; i<string.length; i++) {
		NSString *c = [string substringWithRange:NSMakeRange(i, 1)];
		NSString *replace;
		if ((replace = [self.dakuten objectForKey:c])) {
			//濁点の差し替えがあれば差し替える
			[ret appendString:replace];
		}
		else {
			[ret appendString:c];
		}
	}
	return ret;
}

//文字をセンタリングする
- (void) setCentering:(CGPoint)center {
	int y = center.y;
	int x = center.x -[self getSize].width/2;
	self.position = ccp(x,y);
}

//文字を右揃えにする
- (void) setRighting:(CGPoint)right {
	int y = right.y;
	int x = right.x -[self getSize].width;
	self.position = ccp(x,y);
}

//文字の表示領域を返す
- (CGSize) getSize {
	CCSprite *s;
	int xst,xed;
	int y;
	s = [chars objectAtIndex:0];
	xst = s.position.x;
	y = s.contentSize.height;
	s = [chars lastObject];
	xed = s.position.x+s.contentSize.width*2;
	return CGSizeMake(xed-xst, y);
}

//指定座標が文字の表示領域内に入っているかどうかをチェック
//少しチェックは甘めにします
- (BOOL) isHitByPosition:(CGPoint)pos {
	CGSize size = [self getSize];
	if (pos.x >= self.position.x-8 &&
		pos.x <= self.position.x+size.width+8 &&
		pos.y >= self.position.y-8 &&
		pos.y <= self.position.y+size.height+8) {
		return TRUE;
	}
	return FALSE;
}

//指定のキャラクターのCGRectを返す
- (CGRect)getRectWithString:(NSString*)s {
	NSArray *rect = [characters objectForKey:s];
	if (rect) {
		//CGPoint o = texFontMini;
		float x = [[rect objectAtIndex:0] intValue];
		float y = [[rect objectAtIndex:1] intValue];
		float width = [[rect objectAtIndex:2] intValue];
		float height = [[rect objectAtIndex:3] intValue];
		//return CGRectMake(x+o.x, y+o.y, width, height);
		return CGRectMake(x, y, width, height);
	}
	else {
		return CGRectZero;
	}
}

//指定のキャラクターのフレームを返す
- (CCSpriteFrame*)getFrameWithString:(NSString*)s isShadow:(BOOL)isShadow {
	CGRect rect = [self getRectWithString:s];
	if (isShadow) rect.origin.x += 64;
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"fontProportional.png"];
	CCSpriteFrame *f = [CCSpriteFrame frameWithTexture:texture
										  rectInPixels:rect
											   rotated:NO
												offset:CGPointZero
										  originalSize:rect.size];
	return f;
}

//色を設定する
- (void) setColor:(ccColor3B)_color {
	self.textColor = _color;
	if (shadowOpacity>0) {
		CCSprite *s;
		int i=0;
		CCARRAY_FOREACH(self.chars, s) {
			//文字色だけ変更
			if (i%2 == 1) s.color = _color;
			i++;
		}
	}
	else {
		CCSprite *s;
		CCARRAY_FOREACH(self.chars, s) {
			s.color = _color;
		}
	}
}

//指定の親に子供をすべて移し替える
- (void) transferAllChildrenToNewParent:(CCNode*)node {
	CCSprite *s;
	CCARRAY_FOREACH(chars, s) {
		//スプライトの座標は親の座標を計上したものに修正する
		s.position = ccpAdd(self.position, s.position);
		
		[s removeFromParentAndCleanup:NO];
		[node addChild:s];
	}
}

//指定の親に子供をすべて移し替える
- (void) transferAllChildrenToNewParent:(CCNode*)node z:(int)z {
	CCSprite *s;
	CCARRAY_FOREACH(chars, s) {
		//スプライトの座標は親の座標を計上したものに修正する
		s.position = ccpAdd(self.position, s.position);
		
		[s removeFromParentAndCleanup:NO];
		[node addChild:s z:z];
	}
}

//各ノードにアクションを割り当てる
- (void)runEachNodeWithAction:(id)action {
	CCSprite *s;
	CCARRAY_FOREACH(chars, s) {
		[s runAction:CCCA(action)];
	}
}

@end
