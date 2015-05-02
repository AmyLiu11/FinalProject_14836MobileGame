//
//  LevelView.m
//  LetterGame
//
//  Created by Xiaofen Liu on 4/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LevelView.h"
#import "LGDefines.h"
#import "SpeedMode.h"

@implementation LevelView{
    CCSprite * _LevelThree;
    CCSprite * _LevelTwo;
    CCSprite * _LevelOne;
    CCButton * _backbtn;
    CCSprite * _LevelTwoLock;
    CCSprite * _LevelThreeLock;
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
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber * startover = [userDefaults objectForKey:START_OVER];
    
    if (startover.boolValue == YES){
        [userDefaults setObject:@"easy" forKey:CURRENT_LEVEL];
    }
    NSString * level = [userDefaults stringForKey:CURRENT_LEVEL];
    
    self.userInteractionEnabled = YES;
    
    _LevelTwoLock.opacity = 1;
    _LevelThreeLock.opacity = 1;
    
    if([level isEqualToString:@"medium"]){
            _LevelTwoLock.opacity = 0;
            _LevelThreeLock.opacity = 1;
    }else if([level isEqualToString:@"hard"]){
            _LevelTwoLock.opacity = 0;
            _LevelThreeLock.opacity = 0;
    }
}


-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint pt = [touch locationInNode:self.parent];
    if (CGRectContainsPoint(_LevelOne.boundingBox, pt)) {
        CCLOG(@"touch Level One");
        CCScene * speedModeScene = [CCBReader loadAsScene:@"SpeedMode"];
        SpeedMode * ccscene = [[speedModeScene children] firstObject];
        ccscene.currentScene = @"easy";
        [[CCDirector sharedDirector] replaceScene:speedModeScene];
    }
    
    if (CGRectContainsPoint(_LevelTwo.boundingBox, pt)) {
        CCLOG(@"touch Level Two");
        if(_LevelTwoLock.opacity == 0){
            CCScene * speedModeScene = [CCBReader loadAsScene:@"SpeedMode"];
            SpeedMode * ccscene = [[speedModeScene children] firstObject];
            ccscene.currentScene = @"medium";
            [[CCDirector sharedDirector] replaceScene:speedModeScene];
        }
    }
    
    if (CGRectContainsPoint(_LevelThree.boundingBox, pt)) {
        CCLOG(@"touch Level Three");
         if(_LevelThreeLock.opacity == 0){
             CCScene * speedModeScene = [CCBReader loadAsScene:@"SpeedMode"];
             SpeedMode * ccscene = [[speedModeScene children] firstObject];
             ccscene.currentScene = @"hard";
             [[CCDirector sharedDirector] replaceScene:speedModeScene];
         }
    }
}

- (void)goBack{
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"PlayModeSelection"]];
}










@end
