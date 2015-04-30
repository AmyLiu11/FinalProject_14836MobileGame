//
//  LoseScene.m
//  LetterGame
//
//  Created by Xiaofen Liu on 4/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LoseScene.h"
#import "LGDefines.h"

@implementation LoseScene


- (void)back{
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"PlayModeSelection"]];
}

- (void)tryAgain{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NOTIFICATION_TRY_AGAIN object:self];
}

@end
