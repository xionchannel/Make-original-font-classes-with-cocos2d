//
//  emFont.h
//
//  Created by xionchannel on 10/04/24.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "cocos2d.h"

@interface emFont : CCNode {
	CCArray *chars;
	CCNode *childrensParent;
	int childrensZ;
}
@property (nonatomic, retain) CCArray* chars;
@property (nonatomic, assign) CCNode* childrensParent;
@property (assign) int childrensZ;

+ (id)fontWithText:(NSString*)string;
+ (id) fontWithNumber:(int64_t)num keta:(int)keta;
+ (NSString*)getStringWithNumber:(int64_t)num keta:(int)keta;

- (void)changeText:(NSString*)string;
- (void)setText:(NSString*)string;
- (void) changeTextWithNumber:(int64_t)num keta:(int)keta;
- (void) setTextWithNumber:(int64_t)num keta:(int)keta;

- (CGRect)getRectWithASCII:(char)ascii;
- (CCSpriteFrame*)getFrameWithASCII:(char)ascii;
- (void) setColor:(ccColor3B)color;
- (void) setCentering:(CGPoint)center;
- (void) setRighting:(CGPoint)right;
- (CGSize) getSize;
- (BOOL) isHitByPosition:(CGPoint)pos;

- (void) transferAllChildrenToNewParent:(CCNode*)node;
- (void) transferAllChildrenToNewParent:(CCNode*)node z:(float)z;
- (void) deleteAllCharacters;

@end
