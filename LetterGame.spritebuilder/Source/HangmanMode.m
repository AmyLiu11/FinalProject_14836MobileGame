//
//  HangmanMode.m
//  LetterGame
//
//  Created by Xiaofen Liu on 3/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "HangmanMode.h"
#import "Hangman.h"
#import "LGDefines.h"
#import "Utils.h"

@interface HangmanMode()

@property (nonatomic, strong) NSMutableArray * hangmanArr;
@property (nonatomic, assign) CCTime countDown;
@property (nonatomic, strong) LetterBoard * lb;
@property (nonatomic, strong) NSNumber * hmnum;
@property (nonatomic, strong) CCScene * loseScene;
@property (nonatomic, strong) CCScene * timeUpScene;


@end
@implementation HangmanMode{
    CCNodeColor * _contentNode;
    CCButton * _backbtn;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_timeLabel;
    CCTimer *_timer;
}

- (void)onEnter{
    [super onEnter];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithInt:2] forKey:GAME_PLAY_SCENE];
    NSNumber * resume = [userDefaults objectForKey:START_OVER];
    
    BOOL resumed = resume.boolValue;
    
    CCButton * invibtn = [CCButton buttonWithTitle:@"cg"];
    [_backbtn addChild:invibtn];
    invibtn.position = CGPointMake(22, 24);
    [invibtn setTarget:self selector:@selector(goBack)];
    [invibtn setColorRGBA:[CCColor clearColor]];
    [invibtn setBackgroundColor:[CCColor clearColor] forState:CCControlStateNormal];
    [invibtn setBackgroundColor:[CCColor clearColor] forState:CCControlStateSelected];

    if (!resumed) {
        NSNumber * wordIndex = [userDefaults objectForKey:H_INDEX_KEY];
        
        if (!wordIndex) {
            self.index = 0;
        }else{
            self.index = [wordIndex integerValue];
        }
        
        NSNumber * score = [userDefaults objectForKey:H_TOTAL_SCORE];
        self.totalScore = score.integerValue;
    }else{
        self.index = 0;
        self.totalScore = 0;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSNumber numberWithInteger:self.totalScore] forKey:H_TOTAL_SCORE];
        [userDefaults setObject:[NSNumber numberWithInteger:self.index] forKey:H_INDEX_KEY];
    }

    
    [self schedule:@selector(updateTimeAndScore) interval:1.0f];
    
    self.model = [HangmanModel modelWithLevel];
    self.step = -1;
    self.countDown = self.model.timeToSolve;
    self.pointsPerTile = self.model.pointPerTile;
    _scoreLabel.string = [NSString stringWithFormat:@"%lu", (unsigned long)self.totalScore];
    _timeLabel.string = [Utils transTime:(time_t)self.countDown];
    
    NSArray * wordArr = [self.model.anagramPairs objectAtIndex:self.index];
    self.hmnum = [wordArr objectAtIndex:0];
    
    CGFloat hm_h = [self layoutHmWithNum:[self.hmnum integerValue]];
    
    self.lb = [[LetterBoard alloc] initWithBeforeWord:[wordArr objectAtIndex:1] afterW:[wordArr objectAtIndex:2] withCount:self.model.anagramPairs.count];
    self.lb.delegate = self;
    [self.lb preloadSoundEffect];
    [_contentNode addChild:self.lb];
    self.lb.anchorPoint = ccp(0.0f,0.0f);
    self.lb.scaleX = 0.3f;
    CGPoint worldPoint = ccp(0,hm_h - 200);
    CGPoint contentPoint = [_contentNode convertToNodeSpace:worldPoint];
    self.lb.position = contentPoint;
    
    [self schedule:@selector(updateTimeAndScore) interval:1.0f];
    
    if (!_timer) {
        _timer = [[CCTimer alloc] init];
    }
    NSLog(@"width:%f height:%f", _contentNode.contentSize.width, _contentNode.contentSize.height);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailTheGame)
                                                 name:NOTIFICATION_TRY_AGAIN
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishTheGame)
                                                 name:NOTIFICATION_FINISHGAME
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReachTimeUp)
                                                 name:NOTIFICATION_TIME_UP
                                               object:nil];
    
}

- (CGFloat)layoutHmWithNum:(NSUInteger)num{
    CGFloat hm_h = 0.0f;
    if (num > 0) {
        for (int i = 0; i < num; i++) {
            CCNode * hm = [CCBReader load:@"hangman"];
            Hangman * initialHM = [(Hangman*)hm getInitialHangman];
            initialHM.scaleX = 0.3f;
            CGPoint worldPoint = ccp(HM_LEFT_PADDING + i*(100 + HM_GAP), _contentNode.contentSize.height - HM_UP_PADDING);
            CGPoint contentPoint = [_contentNode convertToNodeSpace:worldPoint];
            initialHM.position = contentPoint;
        
            initialHM.anchorPoint = ccp(0.5f, 0.5f);
            initialHM.name = [NSString stringWithFormat:@"%d",i];
            [_contentNode addChild:initialHM];
            hm_h = initialHM.position.y;
        }
    }
    return hm_h;
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

- (void)showHangmanWithlb:(LetterBoard*)lb{
    self.step++;
    if (self.step == (HM_DIE_STEP * self.hmnum.intValue - 1)) {
        CCScene * timeUpScene = [CCBReader loadAsScene:@"LoseScene"];
        self.loseScene = timeUpScene;
        CGFloat screenWidth = [Utils getScreenWidth];
        CGFloat screenHeight = [Utils getScreenHeight];
        self.loseScene.position = CGPointMake(screenWidth/2.0, screenHeight/2.0);
        [self addChild:self.loseScene];
        return;
    }
    
    int hangmanTag = (int)self.step / HM_DIE_STEP;
    CCNode * node = [_contentNode getChildByName:[NSString stringWithFormat:@"%d",hangmanTag] recursively:NO];
    if ([node isKindOfClass:[Hangman class]]) {
        Hangman * hm = (Hangman*)node;
        [hm showHangmanWithStep:(self.step % HM_DIE_STEP)];
    }
}

- (void)setUpCharacter{
    NSMutableArray * tempArr = [self.model.anagramPairs objectAtIndex:self.index];
    self.hmnum = [tempArr objectAtIndex:0];
    [self layoutHmWithNum:[self.hmnum integerValue]];
    [self.lb resetBoardWithbw:[tempArr objectAtIndex:1] afterW:[tempArr objectAtIndex:2]];
}

#pragma mark - Letter board Delegate

- (void)finishSpeedModeWithlb:(LetterBoard*)lb{
    [self unschedule:@selector(updateTimeAndScore)];
    self.index = 0;
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithInteger:self.index] forKey:H_INDEX_KEY];
    
    CCScene * timeUpScene = [CCBReader loadAsScene:@"PassScene"];
    self.loseScene = timeUpScene;
    CGFloat screenWidth = [Utils getScreenWidth];
    CGFloat screenHeight = [Utils getScreenHeight];
    self.loseScene.position = CGPointMake(screenWidth/2.0, screenHeight/2.0);
    [self addChild:self.loseScene];
}


- (void)didFinishOneAnagram:(LetterBoard*)lb{
    self.index = self.model.anagramPairs.count - 1;
//    self.index++;
    self.totalScore += self.model.pointPerTile;
    [self enterNextWord];
}

- (void)clearUpHangman{
    for (int i = 0; i < [self.hmnum intValue]; i++) {
         [_contentNode removeChildByName:[NSString stringWithFormat:@"%d",i]];
    }
}


- (void)goBack{
    self.index = 0;
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"PlayModeSelection"]];
}

- (void)tryAgain{
    [self schedule:@selector(updateTimeAndScore) interval:1.0f];
    self.countDown = self.model.timeToSolve;
    _timeLabel.string = [Utils transTime:(time_t)self.countDown];
    [self enterNextWord];
}

- (void)restoreToInitalLevel{
    self.index = 0;
    self.totalScore = 0;
    [self enterNextWord];
}

- (void)enterNextWord{
    self.step = -1;
    [self clearUpHangman];
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithInteger:self.index] forKey:H_INDEX_KEY];
    [self setUpCharacter];
}

- (void)hint{
    [self.lb findFirstUnmatchedBox];
}

- (void)didFailTheGame{
    [self.loseScene removeFromParent];
    [self tryAgain];
}

- (void)didFinishTheGame{
    [self.loseScene removeFromParent];
    [self restoreToInitalLevel];
}

- (void)didReachTimeUp{
    [self.timeUpScene removeFromParent];
    [self tryAgain];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
