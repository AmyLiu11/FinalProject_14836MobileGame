//
//  SpeedMode.m
//  LetterGame
//
//  Created by Xiaofen Liu on 3/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LGDefines.h"
#import "Utils.h"
#import "SpeedMode.h"
#import "LetterBox.h"


@interface SpeedMode()

@property (nonatomic, assign) CCTime countDown;
@property (nonatomic, strong) LetterBoard * lb;
@property (nonatomic, strong) CCScene * timeUpScene;
@property (nonatomic, strong) CCScene * finishScene;
@property (nonatomic, strong) CCScene * passScene;
@property (nonatomic, assign) NSInteger hintTime;

@end


@implementation SpeedMode{
    CCTimer *_timer;
    CCLabelTTF *_timeLabel;
    CCLabelTTF *_scoreLabel;
    CCNode * _contentNode;
    CCSprite * _backbtn;
}


- (void)onEnter
{
    [super onEnter];
    
    [_contentNode setOpacity:0.0f];
    
    CCButton * invibtn = [CCButton buttonWithTitle:@"cg"];
    [_backbtn addChild:invibtn];
    invibtn.position = CGPointMake(22, 24);
    [invibtn setTarget:self selector:@selector(goBack)];
    [invibtn setColorRGBA:[CCColor clearColor]];
    [invibtn setBackgroundColor:[CCColor clearColor] forState:CCControlStateNormal];
    [invibtn setBackgroundColor:[CCColor clearColor] forState:CCControlStateSelected];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithInt:1] forKey:GAME_PLAY_SCENE];
    NSNumber * startagain = [userDefaults objectForKey:START_OVER];
    
    if (!startagain.boolValue) {
        
        if(self.currentScene == nil){
             self.currentScene = [userDefaults objectForKey:CURRENT_LEVEL];
        }
        
        if([self.currentScene isEqualToString:@"easy"]){
            NSNumber * wordIndex = [userDefaults objectForKey:EASY_INDEX_KEY];
            self.index = wordIndex ? wordIndex.integerValue : 0;
        }else if ([self.currentScene isEqualToString:@"medium"]){
            NSNumber * wordIndex = [userDefaults objectForKey:MEDI_INDEX_KEY];
            self.index = wordIndex ? wordIndex.integerValue : 0;
        }else{
            NSNumber * wordIndex = [userDefaults objectForKey:HARD_INDEX_KEY];
            self.index = wordIndex ? wordIndex.integerValue : 0;
        }
        NSNumber * score = [userDefaults objectForKey:S_TOTAL_SCORE];
        NSNumber * hint = [userDefaults objectForKey:HINT_S];
        self.totalScore = score.integerValue;
        self.hintTime = hint.integerValue;
        
    }else{
        self.index = 0;
        self.currentScene = @"easy";
        self.hintTime = HINT_TIME_FOR_S;
        self.totalScore = 0;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSNumber numberWithInteger:self.totalScore] forKey:S_TOTAL_SCORE];
        [userDefaults setObject:[NSNumber numberWithInteger:self.index] forKey:EASY_INDEX_KEY];
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:START_OVER];
    }
    
    [userDefaults setObject:self.currentScene forKey:CURRENT_LEVEL];
    
    self.speedModel = [LevelModel modelWithLevel:self.currentScene];
    self.countDown = self.speedModel.timeToSolve;
//    self.countDown = 4;
    self.pointsPerTile = self.speedModel.pointPerTile;
    
    NSArray * wordArr = [self.speedModel.anagramPairs objectAtIndex:self.index];
    [_scoreLabel setColor:[CCColor redColor]];
    [_timeLabel setColor:[CCColor redColor]];
    _timeLabel.string = [Utils transTime:(time_t)self.countDown];
    _scoreLabel.string = [NSString stringWithFormat:@"%lu", (unsigned long)self.totalScore];
    
    [self schedule:@selector(updateTimeAndScore) interval:1.0f];
    
    self.lb = [[LetterBoard alloc] initWithBeforeWord:[wordArr objectAtIndex:0] afterW:[wordArr objectAtIndex:1] withCount:self.speedModel.anagramPairs.count];
    self.lb.delegate = self;
    [self addChild:self.lb];
    [self.lb preloadSoundEffect];
    
    if (!_timer) {
         _timer = [[CCTimer alloc] init];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReachTimeUp)
                                                 name:NOTIFICATION_TIME_UP
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishTheGame)
                                                 name:NOTIFICATION_FINISHGAME
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didPassMedium)
                                                 name:NOTIFICATION_PLAY_HARD
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didPassEasy)
                                                 name:NOTIFICATION_PLAY_MEDIUM
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(continuePlayHard)
                                                 name:NOTIFICATION_CONTINUE_HARD
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(continuePlayMedium)
                                                 name:NOTIFICATION_CONTINUE_MEDIUM
                                               object:nil];

}

- (void)setUpCharacter{
    NSMutableArray * tempArr = [self.speedModel.anagramPairs objectAtIndex:self.index];
    [self.lb resetBoardWithbw:[tempArr objectAtIndex:0] afterW:[tempArr objectAtIndex:1]];
}

- (void)showPassView{
    CGFloat screenWidth = [Utils getScreenWidth];
    CGFloat screenHeight = [Utils getScreenHeight];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([self.currentScene isEqualToString:@"easy"]){
        [userDefaults setObject:@"medium" forKey:CURRENT_LEVEL];
        CCScene * passScene = [CCBReader loadAsScene:@"SpeedPassScene"];
        self.passScene = passScene;
        self.passScene.position = CGPointMake(screenWidth/2.0, screenHeight/2.0);
        [self addChild:self.passScene];
        [userDefaults setObject:[NSNumber numberWithInteger:self.totalScore] forKey:S_PREEASY_SCORE];
    }else if ([self.currentScene isEqualToString:@"medium"]){
        [userDefaults setObject:@"hard" forKey:CURRENT_LEVEL];
        CCScene * passScene = [CCBReader loadAsScene:@"SpeedMediumPassScene"];
        self.passScene = passScene;
        self.passScene.position = CGPointMake(screenWidth/2.0, screenHeight/2.0);
        [self addChild:self.passScene];
        [userDefaults setObject:[NSNumber numberWithInteger:self.totalScore] forKey:S_PREMEDIUM_SCORE];
    }else{
        CCScene * timeUpScene = [CCBReader loadAsScene:@"PassScene"];
        self.finishScene = timeUpScene;
        CGFloat screenWidth = [Utils getScreenWidth];
        CGFloat screenHeight = [Utils getScreenHeight];
        self.finishScene.position = CGPointMake(screenWidth/2.0, screenHeight/2.0);
        [self addChild:self.finishScene];
    }
}


- (void)updateTimeAndScore{
    self.countDown--;
    if (self.countDown < 0) {
        [self unschedule:@selector(updateTimeAndScore)];
        
        if (!self.timeUpScene) {
            CCScene * timeUpScene = [CCBReader loadAsScene:@"AlertView"];
            self.timeUpScene = timeUpScene;
            CGFloat screenWidth = [Utils getScreenWidth];
            CGFloat screenHeight = [Utils getScreenHeight];
            self.timeUpScene.position = CGPointMake(screenWidth/2.0, screenHeight/2.0);
            [self addChild:self.timeUpScene];
        }

        return;
    }
    _timeLabel.string = [Utils transTime:(time_t)self.countDown];
    _scoreLabel.string = [NSString stringWithFormat:@"%lu", (unsigned long)self.totalScore];
    
}


- (void)goBack{
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"LevelView"]];
}

- (void)tryAgain{
    [self schedule:@selector(updateTimeAndScore) interval:1.0f];
     self.countDown = self.speedModel.timeToSolve;
    _timeLabel.string = [Utils transTime:(time_t)self.countDown];
    [self setUpCharacter];
}

- (void)finishSpeedModeWithlb:(LetterBoard*)lb{
    [self unschedule:@selector(updateTimeAndScore)];
    
    CCScene * timeUpScene = [CCBReader loadAsScene:@"PassScene"];
    self.finishScene = timeUpScene;
    CGFloat screenWidth = [Utils getScreenWidth];
    CGFloat screenHeight = [Utils getScreenHeight];
    self.finishScene.position = CGPointMake(screenWidth/2.0, screenHeight/2.0);
    [self addChild:self.finishScene];
}

- (void)enterNextLevelWithlb:(LetterBoard*)lb{
    [self showPassView];
}

- (void)didFinishOneAnagram:(LetterBoard*)lb{
//    self.index++;
    self.index = self.speedModel.anagramPairs.count - 1;
    [self saveIndexKeyForLevel:self.currentScene];
    [self setUpCharacter];
}

- (void)saveIndexKeyForLevel:(NSString*)level{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    
    if([self.currentScene isEqualToString:@"easy"]){
        [userDefault setObject:[NSNumber numberWithInteger:self.index] forKey:EASY_INDEX_KEY];
    }else if ([self.currentScene isEqualToString:@"medium"]){
        [userDefault setObject:[NSNumber numberWithInteger:self.index] forKey:MEDI_INDEX_KEY];
    }else{
        [userDefault setObject:[NSNumber numberWithInteger:self.index] forKey:HARD_INDEX_KEY];
    }
}

- (void)didReachTimeUp{
    [self.timeUpScene removeFromParent];
    [self tryAgain];
}

- (void)didFinishTheGame{
    [self.finishScene removeFromParent];
    [self restoreToLevel:@"easy"];
}

- (void)didPassEasy{
    [self.passScene removeFromParent];
    [self restoreToLevel:@"easy"];
}

- (void)didPassMedium{
    [self.passScene removeFromParent];
    [self restoreToLevel:@"medium"];
}

- (void)continuePlayHard{
    [self.passScene removeFromParent];
    [self continueToNextLevel:@"hard"];
}

- (void)continuePlayMedium{
    [self.passScene removeFromParent];
    [self continueToNextLevel:@"medium"];
}

- (void)restoreToLevel:(NSString*)level{
    self.index = 0;
    [self schedule:@selector(updateTimeAndScore) interval:1.0f];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber * highNumber = [userDefaults objectForKey:S_HIGH_SCORE];
    NSUInteger hscore = highNumber.integerValue < self.totalScore ? self.totalScore : highNumber.integerValue;
    [userDefaults setObject:[NSNumber numberWithInteger:hscore] forKey:S_HIGH_SCORE];
    NSNumber * preScore = nil;
    if ([level isEqualToString:@"medium"]) {
        preScore = [userDefaults objectForKey:S_PREEASY_SCORE];
    }else if ([level isEqualToString:@"hard"]){
        preScore = [userDefaults objectForKey:S_PREMEDIUM_SCORE];
    }else{
        preScore = 0;
    }
    self.totalScore = preScore.integerValue;
    self.currentScene = level;
    [userDefaults setObject:level forKey:CURRENT_LEVEL];
    [self saveIndexKeyForLevel:self.currentScene];
    self.speedModel = [LevelModel modelWithLevel:self.currentScene];
    self.countDown = self.speedModel.timeToSolve;
    self.pointsPerTile = self.speedModel.pointPerTile;
    [userDefaults setObject:[NSNumber numberWithInteger:self.totalScore] forKey:S_TOTAL_SCORE];
    [self enterNextWord];
}

- (void)continueToNextLevel:(NSString*)level{
    self.index = 0;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber * highNumber = [userDefaults objectForKey:S_HIGH_SCORE];
    NSUInteger hscore = highNumber.integerValue < self.totalScore ? self.totalScore : highNumber.integerValue;
    [userDefaults setObject:[NSNumber numberWithInteger:hscore] forKey:S_HIGH_SCORE];
    self.currentScene = level;
    [userDefaults setObject:level forKey:CURRENT_LEVEL];
    [self saveIndexKeyForLevel:self.currentScene];
    self.speedModel = [LevelModel modelWithLevel:self.currentScene];
    self.countDown = self.speedModel.timeToSolve;
    self.pointsPerTile = self.speedModel.pointPerTile;
    [userDefaults setObject:[NSNumber numberWithInteger:self.totalScore] forKey:S_TOTAL_SCORE];
    [self enterNextWord];

}


- (void)enterNextWord{
    [self setUpCharacter];
}

- (void)hint{
    self.hintTime--;
    if(self.hintTime < 0){
        return;
    }
    [self.lb findFirstUnmatchedBox];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onExit{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber * highNumber = [userDefaults objectForKey:S_HIGH_SCORE];
    NSUInteger hscore = highNumber.integerValue < self.totalScore ? self.totalScore : highNumber.integerValue;
    [userDefaults setObject:[NSNumber numberWithInteger:hscore] forKey:S_HIGH_SCORE];
    [userDefaults setObject:[NSNumber numberWithInteger:self.totalScore] forKey:S_TOTAL_SCORE];
    [userDefaults setObject:[NSNumber numberWithInteger:self.hintTime] forKey:HINT_S];
    [super onExit];
}


@end
