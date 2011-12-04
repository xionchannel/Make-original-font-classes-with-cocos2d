//
//  emFontProportional.h
//
//  Created by xionchannel software on 11/04/06.
//  Copyright 2011 xionchannel software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface emFontProportional : CCNode {
	NSDictionary *characters;
	NSDictionary *dakuten;
	CCArray *chars;
}
@property (nonatomic,retain) CCArray* chars;
@property (nonatomic,retain) NSDictionary *characters;
@property (nonatomic,retain) NSDictionary *dakuten;
@property (assign) ccColor3B textColor;
@property (assign) ccColor3B shadowColor;
@property (assign) int shadowOpacity;

+ (id)fontWithText:(NSString*)string;
+ (id)fontWithText:(NSString*)string invert:(BOOL)inv;

- (void)setText:(NSString*)string;
- (void)setText:(NSString*)string 
		  color:(ccColor3B)_color
	shadowColor:(ccColor3B)_shadowColor
  shadowOpacity:(int)_shadowOpacity;

- (CGRect)getRectWithString:(NSString*)s;
- (CCSpriteFrame*)getFrameWithString:(NSString*)s isShadow:(BOOL)isShadow;
- (void) setColor:(ccColor3B)_color;
- (void) setCentering:(CGPoint)center;
- (void) setRighting:(CGPoint)right;
- (CGSize) getSize;
- (BOOL) isHitByPosition:(CGPoint)pos;
- (void) transferAllChildrenToNewParent:(CCNode*)node;
- (void) transferAllChildrenToNewParent:(CCNode*)node z:(int)z;
- (void)runEachNodeWithAction:(id)action;

@end
