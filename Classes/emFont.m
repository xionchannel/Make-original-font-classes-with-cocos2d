//
//  emFont.m
//
//  Created by xionchannel on 10/04/24.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "emFont.h"

@implementation emFont

@synthesize chars,childrensParent,childrensZ;


//テキストを指定して初期化
+ (id)fontWithText:(NSString*)string {
	emFont *f = [emFont node];
	f.chars = [CCArray array];
	f.childrensParent = f;
	f.childrensZ = 0;
	[f setText:string];
	return f;
}

//指定桁数の数字で表示する
+ (id) fontWithNumber:(int64_t)num keta:(int)keta {
	emFont *f = [emFont node];
	f.chars = [CCArray array];
	f.childrensParent = f;
	f.childrensZ = 0;
	[f setTextWithNumber:num keta:keta];
	return f;
}

- (void)dealloc {
	self.chars = nil;
	[super dealloc];
}

//テキストを変更する
- (void)changeText:(NSString*)string {
	int ccount = self.chars.count;
	int tcount = string.length;
	
	//文字数が減ってたらスプライトの数をけずる
	if (tcount < ccount) {
		for (int i=0; i<ccount-tcount; i++) {
			if (self.children.count>0)
				[self.children removeLastObject];
			CCSprite *s = [self.chars lastObject];
			[s removeFromParentAndCleanup:YES];
			[self.chars removeLastObject];
		}
	}
	else if (tcount > ccount) {
		[self setText:string];
		return;
	}
	
	//テキストをASCIIに変換
	char *c;
	c = malloc((tcount+1)*sizeof(char));
	[string getCString:c maxLength:tcount+1 encoding:NSASCIIStringEncoding];
	
	int i=0;
	CCSprite *s;
	CCARRAY_FOREACH(self.chars, s) {
		[s setTextureRect:[self getRectWithASCII:c[i]]];
		i++;
	}
	
	free(c);
}

//テキストを設定する
- (void)setText:(NSString*)string {
	[self removeAllChildrenWithCleanup:YES];
	CCSprite *s;
	CCARRAY_FOREACH(self.chars, s) {
		[s removeFromParentAndCleanup:YES];
	}
	[chars removeAllObjects];
	
	int tcount = string.length;
	if (tcount==0) return;
	
	//テキストをASCIIに変換
	char *c;
	c = malloc((tcount+1)*sizeof(char));
	[string getCString:c maxLength:tcount+1 encoding:NSASCIIStringEncoding];

	for (int i=0; i<tcount; i++) {
		CCSpriteFrame *f = [self getFrameWithASCII:c[i]];
		CCSprite *s = [CCSprite spriteWithSpriteFrame:f];
		[s.texture setAliasTexParameters];
		s.anchorPoint = ccp(0.5,0.5);
		s.scale = 2.0f;
		s.position = ccp((16*i+8),0);
		s.color = ccWHITE;
		[childrensParent addChild:s z:childrensZ];
		[chars addObject:s];
	}
	
	free(c);
}

//指定桁数の数字を得る
+ (NSString*)getStringWithNumber:(int64_t)num keta:(int)keta {
	NSString *s = [NSString stringWithFormat:@"%%0%uqu",keta];
	return [NSString stringWithFormat:s, num];
}

//指定桁数の数字で表示する
- (void) changeTextWithNumber:(int64_t)num keta:(int)keta {
	[self changeText:[emFont getStringWithNumber:num keta:keta]];
}

//指定桁数の数字で表示する
- (void) setTextWithNumber:(int64_t)num keta:(int)keta {
	[self setText:[emFont getStringWithNumber:num keta:keta]];
}

//文字をセンタリングする
- (void) setCentering:(CGPoint)center {
	int y = center.y;
	int x = center.x -(16*self.chars.count)/2;
	self.position = ccp(x, y);
}

//文字を右揃えにする
- (void) setRighting:(CGPoint)right {
	int y = right.y;
	int x = right.x -(16*self.chars.count);
	self.position = ccp(x,y);
}

//文字の表示領域を返す
- (CGSize) getSize {
	return CGSizeMake(16*self.chars.count, 16);
}

//指定座標が文字の表示領域内に入っているかどうかをチェック
//少しチェックは甘めにします
- (BOOL) isHitByPosition:(CGPoint)pos {
	CGSize size = [self getSize];
	if (pos.x >= self.position.x-8 &&
		pos.x <= self.position.x+size.width-8 &&
		pos.y >= self.position.y-16 &&
		pos.y <= self.position.y+size.height) {
		return TRUE;
	}
	return FALSE;
}

//指定のキャラクターのCGRectを返す
- (CGRect)getRectWithASCII:(char)ascii {
	char c;
	if (ascii>='0' && ascii<='9') {
		c = ascii-'0';
	}
	else if (ascii>='A' && ascii<='Z') {
		c = ascii-'A'+10;
	}
	else if (ascii=='!') {	//!
		c = ('Z'-'A'+10)+1;
	}
	else if (ascii=='?') {	//?
		c = ('Z'-'A'+10)+2;
	}
	else if (ascii=='.') {	//.
		c = ('Z'-'A'+10)+3;
	}
	else if (ascii==',') {	//,
		c = ('Z'-'A'+10)+4;
	}
	else if (ascii=='\'') {	//'
		c = ('Z'-'A'+10)+5;
	}
	else if (ascii=='/') {	//slash
		c = ('Z'-'A'+10)+6;
	}
	else if (ascii=='"') {	//"
		c = ('Z'-'A'+10)+7;
	}
	else {
		c = ('Z'-'A'+10)+8;	//スペースに置き換える
	}
	
	return CGRectMake(8*(c%8), 8*(c/8), 8, 8);
}

//指定のキャラクターのフレームを返す
- (CCSpriteFrame*)getFrameWithASCII:(char)ascii {
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"fontFixed.png"];
	CCSpriteFrame *f = [CCSpriteFrame frameWithTexture:texture
										  rectInPixels:[self getRectWithASCII:ascii]
											   rotated:NO
												offset:CGPointZero
										  originalSize:CGSizeMake(8, 8)];
	
	return f;
}

//色を設定する
- (void) setColor:(ccColor3B)color {
	CCSprite *s;
	CCARRAY_FOREACH(self.chars, s) {
		s.color = color;
	}
}

//指定の親に子供をすべて移し替える
- (void) transferAllChildrenToNewParent:(CCNode*)node {
	CCSprite *s;
	CCARRAY_FOREACH(self.chars, s) {
		//スプライトの座標は親の座標を計上したものに修正する
		s.position = ccpAdd(self.position, s.position);
		
		[s removeFromParentAndCleanup:NO];
		[node addChild:s];
	}
	childrensParent = node;
	childrensZ = 0;
}
- (void) transferAllChildrenToNewParent:(CCNode*)node z:(float)z {
	CCSprite *s;
	CCARRAY_FOREACH(self.chars, s) {
		//スプライトの座標は親の座標を計上したものに修正する
		s.position = ccpAdd(self.position, s.position);
		
		[s removeFromParentAndCleanup:NO];
		[node addChild:s z:z];
	}
	childrensParent = node;
	childrensZ = z;
}

//文字を全て削除
- (void)deleteAllCharacters {
	[self removeAllChildrenWithCleanup:YES];
	CCSprite *s;
	CCARRAY_FOREACH(self.chars, s) {
		[s removeFromParentAndCleanup:YES];
	}
	[self.chars removeAllObjects];
}

@end
