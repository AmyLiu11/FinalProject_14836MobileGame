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


@interface SpeedMode()

@property (nonatomic, assign) CCTime countDown;
@property (nonatomic, strong) LetterBoard * lb;

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
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * level = [userDefaults stringForKey:LEVEL_KEY];
    NSNumber * wordIndex = [userDefaults objectForKey:INDEX_KEY];
    [_contentNode setOpacity:0.0f];
    
    CCButton * invibtn = [CCButton buttonWithTitle:@"cg"];
    [_backbtn addChild:invibtn];
    invibtn.position = CGPointMake(22, 24);
    [invibtn setTarget:self selector:@selector(goBack)];
    [invibtn setColorRGBA:[CCColor clearColor]];
    [invibtn setBackgroundColor:[CCColor clearColor] forState:CCControlStateNormal];
    [invibtn setBackgroundColor:[CCColor clearColor] forState:CCControlStateSelected];
    
    if (!level) {
        self.level = @"easy";
    }else{
        self.level = level;
    }
    
    if (!wordIndex) {
        self.index = 0;
    }else{
        self.index = [wordIndex integerValue];
    }
    
    self.speedModel = [LevelModel modelWithLevel:self.level];
    self.countDown = self.speedModel.timeToSolve;
    self.totalScore = 0;
    
    NSArray * wordArr = [self.speedModel.anagramPairs objectAtIndex:self.index];
    [_scoreLabel setColor:[CCColor redColor]];
    [_timeLabel setColor:[CCColor redColor]];
    _timeLabel.string = [Utils transTime:(time_t)self.countDown];
    _scoreLabel.string = [NSString stringWithFormat:@"%lu", (unsigned long)self.totalScore];
    
    [self schedule:@selector(updateTimeAndScore) interval:1.0f];
    
    self.lb = [[LetterBoard alloc] initWithBeforeWord:[wordArr objectAtIndex:0] afterW:[wordArr objectAtIndex:1] withCount:self.speedModel.anagramPairs.count];
    self.lb.delegate = self;
    [self addChild:self.lb];
    
    if (!_timer) {
         _timer = [[CCTimer alloc] init];
    }
    
}


-(void)enterPreviousLevel{
    if ([self.level isEqualToString:@"easy"]) {
        [self showPassView];
    }else if([self.level isEqualToString:@"medium"]){
        [self showPassView];
    }else{
        [self showPassView];
    }

}

- (void)levelStaff{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.level forKey:LEVEL_KEY];
    self.speedModel = [LevelModel modelWithLevel:self.level];
    self.countDown = self.speedModel.timeToSolve;
    self.index = 0;
    [self setUpCharacter];
}

- (void)setUpCharacter{
    NSMutableArray * tempArr = [self.speedModel.anagramPairs objectAtIndex:self.index];
    [self.lb resetBoardWithbw:[tempArr objectAtIndex:0] afterW:[tempArr objectAtIndex:1]];
}

- (void)showPassView{
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Congratulations!"
                                                     message:[NSString stringWithFormat:@"You have passed %@ level", self.level]
                                                    delegate:self
                                           cancelButtonTitle:@"Quit"
                                           otherButtonTitles: nil];
    alert.tag = 0;
    [alert addButtonWithTitle:@"Enter Next Level"];
    [alert show];
}


- (void)updateTimeAndScore{
    self.countDown--;
    if (self.countDown < 0) {
        [self unschedule:@selector(updateTimeAndScore)];
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Time Up!"
                                                         message:[NSString stringWithFormat:@"You didn't pass %@ level", self.level]
                                                        delegate:self
                                               cancelButtonTitle:@"Quit"
                                               otherButtonTitles: nil];
        alert.tag = 1;
        [alert addButtonWithTitle:@"Try Again"];
        [alert show];
        return;
    }
    _timeLabel.string = [Utils transTime:(time_t)self.countDown];
    _scoreLabel.string = [NSString stringWithFormat:@"%lu", (unsigned long)self.totalScore];
    
}

#pragma mark - Alertview Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        switch (buttonIndex) {
            case 0:
                [self goBack];
                break;
            case 1:
                [self tryAgain];
                break;
            default:
                break;
        }
    }else if(alertView.tag == 0){
        switch (buttonIndex) {
            case 0:
                [self goBack];
                break;
            case 1:
                if ([self.level isEqualToString:@"easy"]) {
                    self.level = @"medium";
                    [self levelStaff];
                }else if([self.level isEqualToString:@"medium"]){
                    self.level = @"hard";
                    [self levelStaff];
                }else{
                    
                }
                break;
            default:
                break;
        }
    }else{
        switch (buttonIndex) {
            case 1:
                [self goBack];
            default:
                break;
        }
    }
}


- (void)goBack{
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"PlayModeSelection"]];
}

- (void)tryAgain{
    [self schedule:@selector(updateTimeAndScore) interval:1.0f];
     self.countDown = self.speedModel.timeToSolve;
    _timeLabel.string = [Utils transTime:(time_t)self.countDown];
    [self setUpCharacter];
}

- (void)finishSpeedModeWithlb:(LetterBoard*)lb{
    [self unschedule:@selector(updateTimeAndScore)];
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Congratulations!"
                                                     message:[NSString stringWithFormat: @"You have played all levels"]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
    alert.tag = 2;
    [alert addButtonWithTitle:@"Quit Speed Mode"];
    [alert show];
}

- (void)enterNextLevelWithlb:(LetterBoard*)lb{
    [self showPassView];
}

- (void)didFinishOneAnagram:(LetterBoard*)lb{
    self.index = 5;//self.index++;
    self.totalScore += 10;
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithInteger:self.index] forKey:INDEX_KEY];
    [self setUpCharacter];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
