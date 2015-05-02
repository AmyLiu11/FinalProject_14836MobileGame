//
//  SpeedMediumPassScene.m
//  LetterGame
//
//  Created by Xiaofen Liu on 5/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpeedMediumPassScene.h"
#import "LGDefines.h"

@implementation SpeedMediumPassScene

- (void)playAgain{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NOTIFICATION_PLAY_HARD object:self];
}

- (void)back{
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"LevelView"]];
}

- (void)playHard{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NOTIFICATION_CONTINUE_HARD object:self];
}

@end
