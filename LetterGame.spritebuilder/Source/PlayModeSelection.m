//
//  PlayModeSelection.m
//  LetterGame
//
//  Created by Xiaofen Liu on 3/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "PlayModeSelection.h"

@implementation PlayModeSelection{
    CCButton * _backbtn;
}

- (void)onEnter{
    [super onEnter];
    CCButton * invibtn = [CCButton buttonWithTitle:@"cg"];
    [_backbtn addChild:invibtn];
    invibtn.position = CGPointMake(22, 24);
    [invibtn setTarget:self selector:@selector(goBack)];
    [invibtn setColorRGBA:[CCColor clearColor]];
    [invibtn setBackgroundColor:[CCColor clearColor] forState:CCControlStateNormal];
    [invibtn setBackgroundColor:[CCColor clearColor] forState:CCControlStateSelected];
}

- (void)showSpeedMode{
//    CCScene * speedModeScene = [CCBReader loadAsScene:@"SpeedMode"];
    CCScene * speedModeScene = [CCBReader loadAsScene:@"LevelView"];
    [[CCDirector sharedDirector] replaceScene:speedModeScene];
}

- (void)showHangmanMode{
    CCScene * speedModeScene = [CCBReader loadAsScene:@"HangmanMode"];
    [[CCDirector sharedDirector] replaceScene:speedModeScene];

}

- (void)goBack{
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"MainScene"]];
}

@end
