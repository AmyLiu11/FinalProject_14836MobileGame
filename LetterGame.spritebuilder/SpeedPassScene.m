//
//  SpeedPassScene.m
//  LetterGame
//
//  Created by Xiaofen Liu on 5/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpeedPassScene.h"
#import "LGDefines.h"

@implementation SpeedPassScene


- (void)playAgain{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NOTIFICATION_PLAY_MEDIUM object:self];
}

- (void)back{
   [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"LevelView"]];
}

- (void)playMedium{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NOTIFICATION_CONTINUE_MEDIUM object:self];
}

@end
