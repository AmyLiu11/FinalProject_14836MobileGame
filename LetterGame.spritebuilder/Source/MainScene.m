#import "MainScene.h"

@implementation MainScene

//- (void)onEnter
//{
//    [super onEnter];
//    NSLog(@"enter main");
//    
//    CCButton * playBtn = [CCButton buttonWithTitle:@"Play"];
//    playBtn.positionInPoints = ccp(160,200);
//    [playBtn setBackgroundColor:[CCColor redColor] forState:CCControlStateNormal];
//    [self addChild:playBtn];
//    [playBtn setBlock:^(id sender){
//        [self play];
//    }];
//    
//    CCButton * scoreBtn = [CCButton buttonWithTitle:@"High Score"];
//    scoreBtn.positionInPoints = ccp(260,200);
//    [scoreBtn setBackgroundColor:[CCColor redColor] forState:CCControlStateNormal];
//    [self addChild:scoreBtn];
//    [scoreBtn setBlock:^(id sender){
//        [self showHighscore];
//    }];
//    
//    CCButton * optionsBtn = [CCButton buttonWithTitle:@"Options"];
//    optionsBtn.positionInPoints = ccp(360,200);
//    [optionsBtn setBackgroundColor:[CCColor redColor] forState:CCControlStateNormal];
//    [self addChild:optionsBtn];
//    [optionsBtn setBlock:^(id sender){
//        [self showOptions];
//    }];
//}

- (void)play{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"PlayModeSelection"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void)showHighscore{
    NSLog(@"highscore");
//    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
//    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void)showOptions{
    NSLog(@"options");
//    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
//    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}
@end
