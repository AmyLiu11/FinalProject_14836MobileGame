//
//  HangmanMode.m
//  LetterGame
//
//  Created by Xiaofen Liu on 3/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "HangmanMode.h"
#import "HangmanModel.h"
#import "Hangman.h"

@interface HangmanMode()

@property (nonatomic, strong) HangmanModel * speedModel;
@property (nonatomic, strong) NSMutableArray * hangmanArr;
@property (nonatomic, assign) NSUInteger step;

@end
@implementation HangmanMode{
    CCNode * _contentNode;
}

- (void)onEnter{
    [super onEnter];
    
    self.step = 0;
    
    self.hangmanArr = [NSMutableArray array];
    CCNode * hm = [CCBReader load:@"hangman"];
    Hangman * initialHM = [(Hangman*)hm getHangmanWithStep:self.step];
    [self addChild:initialHM];
}

@end
