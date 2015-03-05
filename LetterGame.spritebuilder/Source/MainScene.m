#import "MainScene.h"

@implementation MainScene

- (void)onEnter
{
    [super onEnter];
    
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}


@end
