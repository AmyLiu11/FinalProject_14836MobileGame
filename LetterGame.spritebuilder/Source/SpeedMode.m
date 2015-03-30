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
    NSString * level = [userDefaults stringForKey:@"level"];
    NSUInteger wordIndex = [userDefaults integerForKey:@"index"];
    
    if (!level) {
        level = @"easy";
    }
    
    if (!wordIndex) {
        wordIndex = 0;
    }
    
    self.index = wordIndex;
    self.speedModel = [LevelModel modelWithLevel:level];
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
    CGFloat letterLength = [self calculateLetterLength:self.beforeString];
    CGFloat lastX = LETTERBOX_X_GAP * 4;
    
    self.lastLetterYPos = LETTER_INITIAL_Y;
    if (!self.hasMoreWords) {
        NSMutableArray * tempArr = [self splitWord:self.beforeString];
        for (int i = 0 ; i < (int)self.beforeString.length; i++) {
            NSString * lette = [tempArr objectAtIndex:i];
            CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
            CGPoint contentPoint = [_contentNode convertToNodeSpace:worldPoint];
            LetterView * letter = [[LetterView alloc] initWithLetter:lette andPosition:contentPoint andScale:(letterLength / (LETTER_LENGTH * 2))];
            letter.dragDelegate = self;
            lastX += (letterLength + LETTERBOX_BETWEEN_GAP);
            [_contentNode addChild:letter];
        }
    }else{
        for (int j = 0; j < (int)wordArr.count; j++) {
            NSString * str = [wordArr objectAtIndex:j];
            NSMutableArray * temArr = [self splitWord:str];
            if (j > 0) {
                lastX = LETTERBOX_X_GAP * 4;
                self.lastLetterYPos -= (LETTERBOX_Y_GAP + letterLength);
            }
            for (int i = 0 ; i < (int)str.length; i++) {
                CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
                CGPoint contentPoint = [_contentNode convertToNodeSpace:worldPoint];
                LetterView * letter = [[LetterView alloc] initWithLetter:[temArr objectAtIndex:i] andPosition:contentPoint andScale:(letterLength / (LETTER_LENGTH * 2))];
                letter.dragDelegate = self;
                lastX += (letterLength + LETTERBOX_BETWEEN_GAP);
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
    CGFloat letterBoxLength = [self calculateLetterLength:self.afterString];
    
    CGFloat lastX = LETTERBOX_X_GAP * 4;
    self.lastLetterYPos -= LETTER_BOX_GAP;
    
    if (!self.hasMoreWords) {
        NSMutableArray * tempArr = [self splitWord:self.afterString];
        for (int i = 0 ; i < (int)self.afterString.length ; i++){
            NSString * str = [tempArr objectAtIndex:i];
            CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
            CGPoint contentPoint = [_contentNode convertToNodeSpace:worldPoint];
            LetterBox * box = [[LetterBox alloc] initWithPosition:contentPoint withLetter:str withScale:(letterBoxLength / (LETTER_LENGTH * 2))];
            box.letter = str;
            lastX += (letterBoxLength + LETTERBOX_BETWEEN_GAP);
            [_contentNode addChild:box];
            [self.boxArray addObject:box];
        }
    }else{
        for (int j = 0; j < (int)wordArr.count; j++) {
            NSString * str = [wordArr objectAtIndex:j];
            NSMutableArray * temArr = [self splitWord:str];
            if (j > 0) {
                lastX = LETTERBOX_X_GAP * 4;
                self.lastLetterYPos -= (LETTERBOX_Y_GAP + letterBoxLength);
            }
            for (int i = 0 ; i < (int)str.length; i++) {
                NSString * lette = [temArr objectAtIndex:i];
                CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
                CGPoint contentPoint = [_contentNode convertToNodeSpace:worldPoint];
                LetterBox * box = [[LetterBox alloc] initWithPosition:contentPoint withLetter:lette withScale:(letterBoxLength / (LETTER_LENGTH * 2))];
                lastX += (letterBoxLength + LETTERBOX_BETWEEN_GAP);
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
        self.hasMoreWords = YES;
        CGFloat maxLength = 0.0f;
        for (NSString * str in wordArr){
            maxLength = maxLength > str.length ? maxLength : str.length;
        }
        return ((screenWidth - LETTERBOX_X_GAP * 2 - LETTERBOX_BETWEEN_GAP * (maxLength - 1)) / maxLength);
    }else {
        self.hasMoreWords = NO;
        return ((screenWidth - LETTERBOX_X_GAP * 2 - LETTERBOX_BETWEEN_GAP * (tempArr.count - 1)) / tempArr.count);
    }

}

- (void)clear{
    [_contentNode removeAllChildrenWithCleanup:YES];
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
                if (self.index == self.speedModel.anagramPairs.count) {
                    NSLog(@"nextLevel");
                    self.index = 0;
                }
                [self clear];
                self.totalScore += 10;
                self.index++;
                [self.completeString setString:@""];
                NSMutableArray * tempArr = [self.speedModel.anagramPairs objectAtIndex:self.index];
                self.beforeString = [tempArr objectAtIndex:0];
                self.afterString = [tempArr objectAtIndex:1];
                [self.boxArray removeAllObjects];
                [self setupLetters];
                [self setupLetterBox];
            }
            
        } else {
            
            
            
        }
    }
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
    _timeLabel.string = [self transTime];
    _scoreLabel.string = [NSString stringWithFormat:@"%lu", (unsigned long)self.totalScore];
    
}

- (NSString *)transTime{
    NSString  *format = @"%M:%S";
    NSString  *time = [Utils dateInFormat:(time_t)self.countDown format:format];
    return time;
}



@end
