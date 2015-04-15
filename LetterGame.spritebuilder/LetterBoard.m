//
//  LetterBoard.m
//  LetterGame
//
//  Created by Xiaofen Liu on 4/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LetterBoard.h"
#import "LetterBox.h"
#import "LGDefines.h"
#import "Utils.h"
#import "SpeedMode.h"
#import "HangmanMode.h"

@interface LetterBoard()

@property (nonatomic, strong) NSMutableArray * boxArray;
@property (nonatomic, assign) CGFloat lastLetterYPos;
@property (nonatomic, assign) BOOL hasMoreWords;
@property (nonatomic, assign) CGFloat comboletterLength;
@property (nonatomic, strong) NSString * beforeString;
@property (nonatomic, strong) NSMutableString * completeString;
@property (nonatomic, strong) NSString * afterString;
@property (nonatomic, assign) NSUInteger wordCount;

@end

@implementation LetterBoard

- (id)initWithBeforeWord:(NSString*)bw afterW:(NSString*)aw withCount:(NSUInteger)c{
    self = [super init];
    if (self) {
        self.boxArray = [NSMutableArray array];
        self.completeString = [NSMutableString string];
        self.beforeString = bw;
        self.afterString = aw;
        self.wordCount = c;
        [self setupLetters];
        [self setupLetterBox];
    }
    return self;
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
        CGFloat letterGap = 10.0f;
        lastX += self.comboletterLength / 2.0f;
        NSMutableArray * tempArr = [self splitWord:self.beforeString];
        for (int i = 0 ; i < (int)self.beforeString.length; i++) {
            NSString * lette = [tempArr objectAtIndex:i];
            CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
            LetterView * letter = [[LetterView alloc] initWithLetter:lette andPosition:worldPoint  andScale:(self.comboletterLength / (LETTER_LENGTH))];
            letter.dragDelegate = self;
            [letter randomize];
            lastX += (self.comboletterLength + letterGap);
            [self addChild:letter];
        }
    }else{
        CGFloat beforeletterLength = [self calculateLetterLength:self.beforeString];
        CGFloat afterletterLength = [self calculateLetterLength:self.afterString];
        self.comboletterLength = beforeletterLength < afterletterLength ? beforeletterLength : afterletterLength;
        lastX += self.comboletterLength / 2.0f;
        for (int j = 0; j < (int)wordArr.count; j++) {
            NSString * str = [wordArr objectAtIndex:j];
            NSMutableArray * temArr = [self splitWord:str];
            CGFloat letterGap = 10.0f;
            if (j > 0) {
                lastX = LETTERBOX_X_GAP;
                lastX += self.comboletterLength / 2.0f;
                self.lastLetterYPos -= (LETTERBOX_Y_GAP + self.comboletterLength);
            }
            for (int i = 0 ; i < (int)str.length; i++) {
                CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
                LetterView * letter = [[LetterView alloc] initWithLetter:[temArr objectAtIndex:i] andPosition:worldPoint andScale:(self.comboletterLength / (LETTER_LENGTH))];
                letter.dragDelegate = self;
                [letter randomize];
                lastX += (self.comboletterLength + letterGap);
                [self addChild:letter];
            }
        }
    }
}

- (void)setupLetterBox{
    NSArray * wordArr = [self.afterString componentsSeparatedByString:@" "];
    CGFloat lastX = LETTERBOX_X_GAP;
    self.lastLetterYPos -= LETTER_BOX_GAP;
    
    if (!self.hasMoreWords) {
        CGFloat letterBoxLength = [self calculateLetterLength:self.afterString];
        CGFloat letterGap = 10.0f;
        lastX += self.comboletterLength / 2.0f;
        NSMutableArray * tempArr = [self splitWord:self.afterString];
        for (int i = 0 ; i < (int)self.afterString.length ; i++){
            NSString * str = [tempArr objectAtIndex:i];
            CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
            LetterBox * box = [[LetterBox alloc] initWithPosition:worldPoint withLetter:str withScale:(letterBoxLength / (LETTER_LENGTH))];
            box.letter = str;
            box.isMatched = NO;
            lastX += (letterBoxLength + letterGap);
            [self addChild:box];
            [self.boxArray addObject:box];
        }
    }else{
        lastX += self.comboletterLength / 2.0f;
        for (int j = 0; j < (int)wordArr.count; j++) {
            NSString * str = [wordArr objectAtIndex:j];
            NSMutableArray * temArr = [self splitWord:str];
            CGFloat letterGap = 10.0f;
            if (j > 0) {
                lastX = LETTERBOX_X_GAP;
                lastX += self.comboletterLength / 2.0f;
                self.lastLetterYPos -= (LETTERBOX_Y_GAP + self.comboletterLength);
            }
            for (int i = 0 ; i < (int)str.length; i++) {
                NSString * lette = [temArr objectAtIndex:i];
                CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
                LetterBox * box = [[LetterBox alloc] initWithPosition:worldPoint withLetter:lette withScale:(self.comboletterLength / (LETTER_LENGTH ))];
                box.isMatched = NO;
                lastX += (self.comboletterLength + letterGap);
                [self addChild:box];
                [self.boxArray addObject:box];
            }
        }
    }
}


- (NSMutableArray*)splitWord:(NSString*)string{
    NSMutableArray * letterArr = [NSMutableArray array];
    if ([string length] == 0) {
        return letterArr;
    }
    [string enumerateSubstringsInRange:[string rangeOfString:string] options:NSStringEnumerationByComposedCharacterSequences usingBlock: ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
        [letterArr addObject:substring];
    }];
    
    return letterArr;
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
              if ([self.delegate isKindOfClass:[SpeedMode class]]) {
                  SpeedMode * mode = (SpeedMode*)self.delegate;
                  if (mode.index == (mode.speedModel.anagramPairs.count - 1)) {
                        if ([mode.level isEqualToString:@"hard"]) {
                            [self.delegate finishSpeedModeWithlb:self];
                        }else{
                            [self.delegate enterNextLevelWithlb:self];
                        }
                  }else{
                    [self.delegate didFinishOneAnagram:self];
                  }
              }else{
                  HangmanMode * mode = (HangmanMode*)self.delegate;
                  if (mode.index == (mode.model.anagramPairs.count - 1)) {
                      [self.delegate finishSpeedModeWithlb:self];
                  }else{
                      [self.delegate didFinishOneAnagram:self];
                  }
              }
            }
        } else {
            if ([self.delegate isKindOfClass:[SpeedMode class]]) {
                
            }else{
                HangmanMode * mode = (HangmanMode*)self.delegate;
                [mode showHangmanWithlb:self];
            }
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

- (void)resetBoardWithbw:(NSString*)bw afterW:(NSString*)af{
    [self removeAllChildrenWithCleanup:YES];
    self.beforeString = bw;
    self.afterString = af;
    [self.completeString setString:@""];
    [self.boxArray removeAllObjects];
    self.comboletterLength = 0.0f;
    [self setupLetters];
    [self setupLetterBox];
}



@end
