#import "MainScene.h"

@implementation MainScene{
    CCButton *_playButton;
}

- (void)onEnter{
    [super onEnter];
    _playButton.contentSize = CGSizeMake(150, 29);
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
