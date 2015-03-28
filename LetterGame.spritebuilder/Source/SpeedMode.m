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
    
    NSArray * wordArr = [self.speedModel.anagramPairs objectAtIndex:self.index];
    self.beforeString = [wordArr objectAtIndex:0];
    self.afterString = [wordArr objectAtIndex:1];
    [_scoreLabel setColor:[CCColor redColor]];
    [_timeLabel setColor:[CCColor redColor]];
    _timeLabel.string = [self transTime];
    
    [self schedule:@selector(updateTimeAndScore) interval:1.0f];
    
    [self setupLetters];
    
    [self setupLetterBox];
    
    if (!_timer) {
         _timer = [[CCTimer alloc] init];
    }
    
    //    self.userInteractionEnabled = TRUE;
}



- (void)setupLetters{
    NSMutableArray * tempArr = [self splitWord:self.beforeString];

    CGFloat lastX = LETTERBOX_X_GAP;
//    self.lastLetterYPos = _scoreLabel.boundingBox.origin.y + _scoreLabel.boundingBox.size.height + LETTERBOX_Y_GAP;
    self.lastLetterYPos = LETTER_INITIAL_Y;
    for (int i = 0 ; i < (int)self.beforeString.length; i++) {
        NSString * lette = [tempArr objectAtIndex:i];
        if(lastX + LETTER_LENGTH > [Utils getScreenWidth]){
            lastX = LETTERBOX_X_GAP;
            self.lastLetterYPos -= (LETTERBOX_Y_GAP + LETTER_LENGTH);
        }
        CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
        CGPoint contentPoint = [_contentNode convertToNodeSpace:worldPoint];
        LetterView * letter = [[LetterView alloc] initWithLetter:lette andPosition:contentPoint];
        letter.dragDelegate = self;
        lastX += LETTER_LENGTH;
        [_contentNode addChild:letter];
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
    NSMutableArray * tempArr = [self splitWord:self.afterString];
    
    CGFloat lastX = LETTERBOX_X_GAP;
    self.lastLetterYPos -= LETTER_BOX_GAP;
    for (int i = 0 ; i < (int)self.afterString.length ; i++){
        if(lastX + LETTER_LENGTH > [Utils getScreenWidth]){
            lastX = LETTERBOX_X_GAP;
            self.lastLetterYPos += (LETTERBOX_Y_GAP + LETTER_LENGTH);
        }
        CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
        CGPoint contentPoint = [_contentNode convertToNodeSpace:worldPoint];
        LetterBox * box = [[LetterBox alloc] initWithPosition:contentPoint withLetter:[tempArr objectAtIndex:i]];
        lastX += LETTER_LENGTH;
        [_contentNode addChild:box];
        [self.boxArray addObject:box];
    }
    
}

- (void)clear{
    [_contentNode removeAllChildrenWithCleanup:YES];
}

- (void)letterView:(LetterView *)letterView didDragToPoint:(CGPoint)point{
    LetterBox * targetView = nil;
    
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
            if ([self.completeString isEqualToString:self.afterString]) {
                if (self.index == self.speedModel.anagramPairs.count) {
                    NSLog(@"nextLevel");
                    self.index = 0;
                }
                [self clear];
                self.index++;
                [self.completeString setString:@""];
                NSMutableArray * tempArr = [self.speedModel.anagramPairs objectAtIndex:self.index];
                self.beforeString = [tempArr objectAtIndex:0];
                self.afterString = [tempArr objectAtIndex:1];
            }
            
        } else {
            
            
            
        }
    }
}


-(void)placeLetter:(LetterView*)lView atTarget:(LetterBox*)targetView
{
    //    targetView.isMatched = YES;
    //    tileView.isMatched = YES;
    
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
