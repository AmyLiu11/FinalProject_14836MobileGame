#import "MainScene.h"
#import "LGDefines.h"

@implementation MainScene{
    CCLabelTTF * _playLabel;
    CCButton * _playButton;
    CCButton * _resume;
    CCButton * _score;
    BOOL _resumed;
}

- (void)onEnter{
    [super onEnter];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber * hidden = [userDefaults objectForKey:RESUME_HIDDEN];
    
    BOOL resume = hidden.boolValue;
    _resumed = resume;
    
    if(!hidden){
        _resume.enabled = NO;
    }else{
        _resume.enabled = YES;
    }
    
}

- (void)play{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:RESUME_HIDDEN];
    [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:START_OVER];
    [userDefaults setObject:@"easy" forKey:CURRENT_LEVEL];
    
    CCScene *gameplayScene = [CCBReader loadAsScene:@"PlayModeSelection"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void)showHighscore{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"HighScore"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void)resumeGame{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber * gameplayScene = [userDefaults objectForKey:GAME_PLAY_SCENE];
    [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:START_OVER];
    
    CCScene * playScene = nil;
    
    if (gameplayScene.intValue == 1) {
        playScene = [CCBReader loadAsScene:@"SpeedMode"];
    }else if(gameplayScene.intValue == 2){
        playScene = [CCBReader loadAsScene:@"HangmanMode"];
    }else{
        playScene = [CCBReader loadAsScene:@"PlayModeSelection"];
    }
    [[CCDirector sharedDirector] replaceScene:playScene];
}
@end
