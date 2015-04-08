//
//  SpeedMode.m
//  LetterGame
//
//  Created by Xiaofen Liu on 3/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpeedMode.h"
#import "LetterBox.h"
#import "LGDefines.h"
#import "Utils.h"


@interface SpeedMode()

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) NSMutableArray * boxArray;
@property (nonatomic, strong) NSMutableString * completeString;
@property (nonatomic, assign) CGFloat lastLetterYPos;
@property (nonatomic, strong) NSString * beforeString;
@property (nonatomic, strong) NSString * afterString;
@property (nonatomic, assign) NSUInteger totalScore;
@property (nonatomic, assign) CCTime countDown;
@property (nonatomic, assign) BOOL hasMoreWords;
@property (nonatomic, assign) CGFloat comboletterLength;
@property (nonatomic, strong) NSString * level;

@end


@implementation SpeedMode{
    CCTimer *_timer;
    CCLabelTTF *_timeLabel;
    CCLabelTTF *_scoreLabel;
    CCNode * _contentNode;
}


- (void)onEnter
{
    [super onEnter];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * level = [userDefaults stringForKey:LEVEL_KEY];
    NSNumber * wordIndex = [userDefaults objectForKey:INDEX_KEY];
    
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
    self.boxArray = [NSMutableArray array];
    self.completeString = [NSMutableString string];
    self.countDown = self.speedModel.timeToSolve;
    self.totalScore = 0;
    
    NSArray * wordArr = [self.speedModel.anagramPairs objectAtIndex:self.index];
    self.beforeString = [wordArr objectAtIndex:0];
    self.afterString = [wordArr objectAtIndex:1];
    [_scoreLabel setColor:[CCColor redColor]];
    [_timeLabel setColor:[CCColor redColor]];
    _timeLabel.string = [self transTime];
    _scoreLabel.string = [NSString stringWithFormat:@"%lu", (unsigned long)self.totalScore];
    
    [self schedule:@selector(updateTimeAndScore) interval:1.0f];
    
    [self setupLetters];
    
    [self setupLetterBox];
    
    if (!_timer) {
         _timer = [[CCTimer alloc] init];
    }
    
    //    self.userInteractionEnabled = TRUE;
}


- (void)setupLetters{
    NSArray * wordArr = [self.beforeString componentsSeparatedByString:@" "];
    CGFloat lastX = LETTERBOX_X_GAP;
    if (wordArr.count > 0) {
        self.hasMoreWords = YES;
    }else{
        self.hasMoreWords  = NO;
    }
    
    self.lastLetterYPos = LETTER_INITIAL_Y;
    if (!self.hasMoreWords) {
        self.comboletterLength = [self calculateLetterLength:self.beforeString];
        CGFloat letterGap = [self calculateLetterGap:self.beforeString];
        NSMutableArray * tempArr = [self splitWord:self.beforeString];
        for (int i = 0 ; i < (int)self.beforeString.length; i++) {
            NSString * lette = [tempArr objectAtIndex:i];
            CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
            CGPoint contentPoint = [_contentNode convertToNodeSpace:worldPoint];
            LetterView * letter = [[LetterView alloc] initWithLetter:lette andPosition:contentPoint andScale:(self.comboletterLength / (LETTER_LENGTH * 2))];
            letter.dragDelegate = self;
            lastX += (self.comboletterLength + letterGap);
            [_contentNode addChild:letter];
        }
    }else{
        CGFloat beforeletterLength = [self calculateLetterLength:self.beforeString];
        CGFloat afterletterLength = [self calculateLetterLength:self.afterString];
        self.comboletterLength = beforeletterLength < afterletterLength ? beforeletterLength : afterletterLength;
        for (int j = 0; j < (int)wordArr.count; j++) {
            NSString * str = [wordArr objectAtIndex:j];
            NSMutableArray * temArr = [self splitWord:str];
            CGFloat letterGap = [self calculateLetterGap:str];
            if (j > 0) {
                lastX = LETTERBOX_X_GAP;
                self.lastLetterYPos -= (LETTERBOX_Y_GAP + self.comboletterLength);
            }
            for (int i = 0 ; i < (int)str.length; i++) {
                CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
                CGPoint contentPoint = [_contentNode convertToNodeSpace:worldPoint];
                LetterView * letter = [[LetterView alloc] initWithLetter:[temArr objectAtIndex:i] andPosition:contentPoint andScale:(self.comboletterLength / (LETTER_LENGTH * 2))];
                letter.dragDelegate = self;
                lastX += (self.comboletterLength + letterGap);
                [_contentNode addChild:letter];
            }
        }
    }
}


- (NSMutableArray*)splitWord:(NSString*)string{
    NSMutableArray * letterArr = [NSMutableArray array];
    [string enumerateSubstringsInRange:[string rangeOfString:string] options:NSStringEnumerationByComposedCharacterSequences usingBlock: ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
        [letterArr addObject:substring];
    }];

    return letterArr;
}

- (void)setupLetterBox{
    NSArray * wordArr = [self.afterString componentsSeparatedByString:@" "];
    CGFloat lastX = LETTERBOX_X_GAP;
    self.lastLetterYPos -= LETTER_BOX_GAP;
    
    if (!self.hasMoreWords) {
        CGFloat letterBoxLength = [self calculateLetterLength:self.afterString];
        CGFloat letterGap = [self calculateLetterGap:self.beforeString];
        NSMutableArray * tempArr = [self splitWord:self.afterString];
        for (int i = 0 ; i < (int)self.afterString.length ; i++){
            NSString * str = [tempArr objectAtIndex:i];
            CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
            CGPoint contentPoint = [_contentNode convertToNodeSpace:worldPoint];
            LetterBox * box = [[LetterBox alloc] initWithPosition:contentPoint withLetter:str withScale:(letterBoxLength / (LETTER_LENGTH * 2))];
            box.letter = str;
            lastX += (letterBoxLength + letterGap);
            [_contentNode addChild:box];
            [self.boxArray addObject:box];
        }
    }else{
        for (int j = 0; j < (int)wordArr.count; j++) {
            NSString * str = [wordArr objectAtIndex:j];
            NSMutableArray * temArr = [self splitWord:str];
            CGFloat letterGap = [self calculateLetterGap:str];
            if (j > 0) {
                lastX = LETTERBOX_X_GAP;
                self.lastLetterYPos -= (LETTERBOX_Y_GAP + self.comboletterLength);
            }
            for (int i = 0 ; i < (int)str.length; i++) {
                NSString * lette = [temArr objectAtIndex:i];
                CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
                CGPoint contentPoint = [_contentNode convertToNodeSpace:worldPoint];
                LetterBox * box = [[LetterBox alloc] initWithPosition:contentPoint withLetter:lette withScale:(self.comboletterLength / (LETTER_LENGTH * 2))];
                lastX += (self.comboletterLength + letterGap);
                [_contentNode addChild:box];
                [self.boxArray addObject:box];
            }
        }
    }
}

- (CGFloat)calculateLetterLength : (NSString *)str{
    NSArray * wordArr = [str componentsSeparatedByString:@" "];
    NSMutableArray * tempArr = [self splitWord:str];
    CGFloat screenWidth = [Utils getScreenWidth];
    
    if (wordArr.count > 1) {
        CGFloat maxLength = 0.0f;
        for (NSString * str in wordArr){
            maxLength = maxLength > str.length ? maxLength : str.length;
        }
        return ((screenWidth - LETTERBOX_X_GAP * 2 - LETTERBOX_BETWEEN_GAP * (maxLength - 1)) / maxLength);
    }else {
        return ((screenWidth - LETTERBOX_X_GAP * 2 - LETTERBOX_BETWEEN_GAP * (tempArr.count - 1)) / tempArr.count);
    }
}


- (CGFloat)calculateLetterGap:(NSString *)str{
    CGFloat screenWidth = [Utils getScreenWidth];
    NSMutableArray * tempArr = [self splitWord:str];
    CGFloat gap = (screenWidth - self.comboletterLength * tempArr.count - LETTERBOX_X_GAP * 2) / (tempArr.count - 1) ;
    return gap;
}


- (void)clearAndSetup{
    [_contentNode removeAllChildrenWithCleanup:YES];
    self.totalScore += 10;
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithInteger:self.index] forKey:INDEX_KEY];
    [self.completeString setString:@""];
    [self setUpCharacter];
}

- (void)letterView:(LetterView *)letterView didDragToPoint:(CGPoint)point{
    LetterBox * targetView = nil;
    NSString * fixedString = [self.afterString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    for (LetterBox* box in self.boxArray) {
        
        if (CGRectContainsPoint(box.boundingBox, point)) {
            targetView = box;
            break;
        }
    }
    
    if (targetView!=nil) {
        
        //2 check if letter matches
        if ([targetView.letter isEqualToString: letterView.letter]) {
            
            [self.completeString appendString:letterView.letter];
            [self placeLetter:letterView atTarget:targetView];
            if ([self.completeString isEqualToString:fixedString]) {
                if (self.index == (self.speedModel.anagramPairs.count - 1)) {
                     self.totalScore += 10;
                    [_contentNode removeAllChildrenWithCleanup:YES];
                    [self enterNextLevel];
                }else{
                    self.index = 5;
                    [self clearAndSetup];
                    //    self.index++;
                }
            }
        } else {
            
        }
    }
}

-(void)enterNextLevel{
    [self showPassView];
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
    [self.completeString setString:@""];
    self.comboletterLength = 0.0f;
    self.countDown = self.speedModel.timeToSolve;
    self.index = 0;
    [self setUpCharacter];
}

- (void)setUpCharacter{
    NSMutableArray * tempArr = [self.speedModel.anagramPairs objectAtIndex:self.index];
    self.beforeString = [tempArr objectAtIndex:0];
    self.afterString = [tempArr objectAtIndex:1];
    [self.boxArray removeAllObjects];
    self.comboletterLength = 0.0f;
    [self setupLetters];
    [self setupLetterBox];
}

- (void)showPassView{
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Congratulations!"
                                                     message:[NSString stringWithFormat:@"You have passed %@ level", self.level]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
    alert.tag = 0;
    [alert addButtonWithTitle:@"Enter Next Level"];
    [alert show];
}

- (void)finishSpeedMode{
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Congratulations!"
                                                     message:[NSString stringWithFormat: @"You have played all levels"]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
    alert.tag = 2;
    [alert addButtonWithTitle:@"Quit Speed Mode"];
    [alert show];
}



-(void)placeLetter:(LetterView*)lView atTarget:(LetterBox*)targetView
{
    lView.userInteractionEnabled = FALSE;
    
    [UIView animateWithDuration:0.35
                          delay:0.00
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         lView.position = targetView.position;
                         //                         tileView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                         targetView.visible = NO;
                     }];
    
}

- (void)updateTimeAndScore{
    self.countDown--;
    if (self.countDown < 0) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Time Up!"
                                                         message:[NSString stringWithFormat:@"You didn't pass %@ level", self.level]
                                                        delegate:self
                                               cancelButtonTitle:@"Quit"
                                               otherButtonTitles: nil];
        alert.tag = 1;
        [alert addButtonWithTitle:@"Try Again"];
        [alert show];
    }
    _timeLabel.string = [self transTime];
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
            case 1:
                if ([self.level isEqualToString:@"easy"]) {
                    self.level = @"medium";
                    [self levelStaff];
                }else if([self.level isEqualToString:@"medium"]){
                    self.level = @"hard";
                    [self levelStaff];
                }else{
                     [self finishSpeedMode];
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
    [self enterNextLevel];
}

- (NSString *)transTime{
    NSString  *format = @"%M:%S";
    NSString  *time = [Utils dateInFormat:(time_t)self.countDown format:format];
    return time;
}



@end
