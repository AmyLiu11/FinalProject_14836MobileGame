//
//  PlayModeSelection.m
//  LetterGame
//
//  Created by Xiaofen Liu on 3/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "PlayModeSelection.h"

@implementation PlayModeSelection

- (void)showSpeedMode{
    CCScene * speedModeScene = [CCBReader loadAsScene:@"SpeedMode"];
    [[CCDirector sharedDirector] replaceScene:speedModeScene];
}

- (void)showHangmanMode{
    CCScene * speedModeScene = [CCBReader loadAsScene:@"HangmanMode"];
    [[CCDirector sharedDirector] replaceScene:speedModeScene];

}

@end
