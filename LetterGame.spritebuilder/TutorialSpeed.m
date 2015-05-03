//
//  TutorialSpeed.m
//  LetterGame
//
//  Created by Xiaofen Liu on 5/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "TutorialSpeed.h"
#import "LGDefines.h"

@implementation TutorialSpeed{
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
        CCLOG(@"touch cancel");
        [self removeFromParent];
        NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:BEGIN_COUNT object:self];
    }
}

@end
