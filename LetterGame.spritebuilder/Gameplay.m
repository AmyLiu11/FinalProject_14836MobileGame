//
//  Gameplay.m
//  LetterGame
//
//  Created by Xiaofen Liu on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "LetterBox.h"


@interface Gameplay()
@property (nonatomic, strong) NSMutableArray * boxArray;
@property (nonatomic, strong) NSMutableString * completeString;

@end
@implementation Gameplay


- (void)onEnter
{
    [super onEnter];
    
    [self setupLetters];
    
    [self setupLetterBox];
    
//    self.userInteractionEnabled = TRUE;
}

- (void)didLoadFromCCB{
    self.userInteractionEnabled = TRUE;
    self.boxArray = [NSMutableArray array];
    self.completeString = [NSMutableString string];
}


- (void)setupLetters{
    NSMutableArray * tempArr = [NSMutableArray arrayWithObjects:@"a",@"p",@"p",@"l",@"e",nil];
    
    for (int i = 4 ; i >= 0; i--) {
        NSUInteger index = arc4random() % (i + 1);
        NSString * lette = [tempArr objectAtIndex:index];
        [tempArr exchangeObjectAtIndex:index withObjectAtIndex:i];
        LetterView * letter = [[LetterView alloc] initWithLetter:lette andPosition:ccp(50 + 100 * i, 100)];
        letter.dragDelegate = self;
        [self addChild:letter];
    }
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
