//
//  AlertView.m
//  LetterGame
//
//  Created by Xiaofen Liu on 4/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "AlertView.h"
#import "LGDefines.h"

@implementation AlertView

- (void)back{
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"PlayModeSelection"]];
}

- (void)tryAgain{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NOTIFICATION_TIME_UP object:self];
}

@end
