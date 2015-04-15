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
    NSNumber * wordIndex = [userDefaults objectForKey:H_INDEX_KEY];
    
    CCButton * invibtn = [CCButton buttonWithTitle:@"cg"];
    [_backbtn addChild:invibtn];
    invibtn.position = CGPointMake(22, 24);
    [invibtn setTarget:self selector:@selector(goBack)];
    [invibtn setColorRGBA:[CCColor clearColor]];
    [invibtn setBackgroundColor:[CCColor clearColor] forState:CCControlStateNormal];
    [invibtn setBackgroundColor:[CCColor clearColor] forState:CCControlStateSelected];

    if (!wordIndex) {
        self.index = 0;
    }else{
        self.index = [wordIndex integerValue];
    }
    
    [self schedule:@selector(updateTimeAndScore) interval:1.0f];
    
    self.model = [HangmanModel modelWithLevel];
    self.step = -1;
    self.totalScore = 0;
    self.countDown = self.model.timeToSolve;
    _scoreLabel.string = [NSString stringWithFormat:@"%lu", (unsigned long)self.totalScore];
    _timeLabel.string = [Utils transTime:(time_t)self.countDown];
    
    NSArray * wordArr = [self.model.anagramPairs objectAtIndex:self.index];
    self.hmnum = [wordArr objectAtIndex:0];
    
    CGFloat hm_h = [self layoutHmWithNum:[self.hmnum integerValue]];
    
    self.lb = [[LetterBoard alloc] initWithBeforeWord:[wordArr objectAtIndex:1] afterW:[wordArr objectAtIndex:2] withCount:self.model.anagramPairs.count];
    self.lb.delegate = self;
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
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Time Up!"
                                                         message:@""
                                                        delegate:self
                                               cancelButtonTitle:@"Quit"
                                               otherButtonTitles: nil];
        alert.tag = 0;
        [alert addButtonWithTitle:@"Try Again"];
        [alert show];
        [self unschedule:@selector(updateTimeAndScore)];
        return;
    }
    _timeLabel.string = [Utils transTime:(time_t)self.countDown];
    _scoreLabel.string = [NSString stringWithFormat:@"%lu", (unsigned long)self.totalScore];
    
}

- (void)showHangmanWithlb:(LetterBoard*)lb{
    self.step++;
    NSLog(@"step %ld",(long)self.step);
    if (self.step == (HM_DIE_STEP * self.hmnum.intValue - 1)) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"You lose!"
                                                         message:@"Sorry, your man are all dead"
                                                        delegate:self
                                               cancelButtonTitle:@"Quit"
                                               otherButtonTitles: nil];
        alert.tag = 1;
        [alert addButtonWithTitle:@"Try Again"];
        [alert show];
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
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Congratulations!"
                                                     message:[NSString stringWithFormat: @"You just saved all man"]
                                                    delegate:self
                                           cancelButtonTitle:@"playAgain?"
                                           otherButtonTitles: nil];
    alert.tag = 2;
    [alert addButtonWithTitle:@"Quit Hangman Mode"];
    [alert show];
}


- (void)didFinishOneAnagram:(LetterBoard*)lb{
//    self.index = self.model.anagramPairs.count - 1;
    self.index++;
    self.totalScore += self.model.pointPerTile;
    [self enterNextWord];
}

- (void)clearUpHangman{
    for (int i = 0; i < [self.hmnum intValue]; i++) {
         [_contentNode removeChildByName:[NSString stringWithFormat:@"%d",i]];
    }
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
                [self tryAgain];
                break;
            default:
                break;
        }
    }else{
        switch (buttonIndex) {
            case 0:
                [self restoreToInitalLevel];
            case 1:
                [self goBack];
            default:
                break;
        }
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


@end
