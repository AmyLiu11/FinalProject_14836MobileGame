#import "MainScene.h"


@implementation MainScene{
    CCLabelTTF * _playLabel;
}

- (void)onEnter{
    [super onEnter];
}

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
