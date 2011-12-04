//
//  MainLayer.h
//
//  Created by xionchannel software on 11/07/19.
//  Copyright 2011 xionchannel software. All rights reserved.
//

#import "cocos2d.h"
#import "emFont.h"
#import "emFontProportional.h"

@interface MainLayer : CCLayer {
	emFont *textFixed;
	emFontProportional *textProportional;
}

+ (CCScene*) scene;
- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end
