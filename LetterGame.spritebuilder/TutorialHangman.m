//
//  TutorialHangman.m
//  LetterGame
//
//  Created by Xiaofen Liu on 5/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "TutorialHangman.h"
#import "LGDefines.h"

@implementation TutorialHangman{
    CCSprite * _cancel;
}

- (void)onEnter{
    [super onEnter];
    self.userInteractionEnabled = YES;
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint pt = [touch locationInNode:self.parent];
    if (CGRectContainsPoint(_cancel.boundingBox, pt)) {
        [self removeFromParent];
        NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:BEGIN_COUNT object:self];
    }
}

@end
