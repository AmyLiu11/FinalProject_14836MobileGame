//
//  SpeedMode.m
//  LetterGame
//
//  Created by Xiaofen Liu on 3/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SpeedMode.h"

@interface SpeedMode()

@property (nonatomic, assign) NSUInteger index;

@end


@implementation SpeedMode{
    CCTimer *_timer;
    CCLabelTTF *_timeLabel;
    CCLabelTTF *_scoreLabel;
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
    
    [self setupLetters];
    
    [self setupLetterBox];
    
    //    self.userInteractionEnabled = TRUE;
}



- (void)setupLetters{
    NSString * word = [self.speedModel.anagramPairs objectAtIndex:self.index];
    NSMutableArray * tempArr = [self splitWord:word];
    
    for (int i = 0 ; i < (int)word.length; i++) {
        NSString * lette = [tempArr objectAtIndex:i];
        LetterView * letter = [[LetterView alloc] initWithLetter:lette andPosition:ccp(10 + 100 * i, 100)];
        letter.dragDelegate = self;
        [self addChild:letter];
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
    NSMutableArray * tempArr = [NSMutableArray arrayWithObjects:@"a",@"p",@"p",@"l",@"e",nil];
    
    for (int i = 0 ; i < 5 ; i++){
        LetterBox * box = [[LetterBox alloc] initWithPosition:ccp(50 + 100 * i, 200) withLetter:[tempArr objectAtIndex:i]];
        [self addChild:box];
        [self.boxArray addObject:box];
    }
    
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
            if ([self.completeString isEqualToString:@"apple"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:@"congratulations!You successfully spell the word 'apple'!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
                [alert show];
                [self.completeString setString:@""];
            }
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong Step!" message:@"Please take another step" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            [alert show];
            
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




@end
