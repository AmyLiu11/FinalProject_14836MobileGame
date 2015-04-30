//
//  PassScene.m
//  LetterGame
//
//  Created by Xiaofen Liu on 4/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "PassScene.h"
#import "LGDefines.h"

@implementation PassScene

- (void)back{
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"PlayModeSelection"]];
}

- (void)tryAgain{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NOTIFICATION_FINISHGAME object:self];
}

@end
