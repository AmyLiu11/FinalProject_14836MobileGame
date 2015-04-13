//
//  Hangman.m
//  LetterGame
//
//  Created by Xiaofen Liu on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Hangman.h"

@interface Hangman()
@property (nonatomic,strong) CCSprite * head;
@property (nonatomic,strong) CCSprite * lefthand;
@property (nonatomic,strong) CCSprite * righthand;
@property (nonatomic,strong) CCSprite * body;
@property (nonatomic,strong) CCSprite * rightleg;
@property (nonatomic,strong) CCSprite * leftleg;
@property (nonatomic,strong) CCSprite * hanger;
@end

@implementation Hangman{
    CCSprite * _hangmanbody;
}

- (id)init{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void)didLoadFromCCB {
    self.head = (CCSprite*)[_hangmanbody getChildByName:@"head" recursively:NO];
    self.lefthand = (CCSprite*)[_hangmanbody getChildByName:@"lefthand" recursively:NO];
    self.righthand = (CCSprite*)[_hangmanbody getChildByName:@"righthand" recursively:NO];
    self.body = (CCSprite*)[_hangmanbody getChildByName:@"body" recursively:NO];
    self.rightleg = (CCSprite*)[_hangmanbody getChildByName:@"rightleg" recursively:NO];
    self.leftleg = (CCSprite*)[_hangmanbody getChildByName:@"leftleg" recursively:NO];
    self.hanger = (CCSprite*)[_hangmanbody getChildByName:@"hanger" recursively:NO];
}

- (Hangman*)getInitialHangman{
    self.head.opacity = 0;
    self.lefthand.opacity = 0;
    self.rightleg.opacity = 0;
    self.body.opacity = 0;
    self.leftleg.opacity = 0;
    self.righthand.opacity = 0;
    return self;
}

- (void)showHangmanWithStep:(NSUInteger)step{
    switch (step) {
        case 0:
            self.head.opacity = 1.0f;
            self.lefthand.opacity = 0;
            self.rightleg.opacity = 0;
            self.body.opacity = 0;
            self.leftleg.opacity = 0;
            self.righthand.opacity = 0;
            break;
        case 1:
            self.head.opacity = 1.0f;
            self.lefthand.opacity = 0;
            self.rightleg.opacity = 0;
            self.body.opacity = 1.0f;
            self.leftleg.opacity = 0;
            self.righthand.opacity = 0;
            break;
        case 2:
            self.head.opacity = 1.0f;
            self.lefthand.opacity = 1.0f;
            self.rightleg.opacity = 0;
            self.body.opacity = 1.0f;
            self.leftleg.opacity = 0;
            self.righthand.opacity = 0;
            break;
        case 3:
            self.head.opacity = 1.0f;
            self.lefthand.opacity = 1.0f;
            self.rightleg.opacity = 0;
            self.body.opacity = 1.0f;
            self.leftleg.opacity = 0;
            self.righthand.opacity = 1.0f;
            break;
        case 4:
            self.head.opacity = 1.0f;
            self.lefthand.opacity = 1.0f;
            self.rightleg.opacity = 0;
            self.body.opacity = 1.0f;
            self.leftleg.opacity = 1.0f;
            self.righthand.opacity = 1.0f;
            break;
        case 5:
            self.head.opacity = 1.0f;
            self.lefthand.opacity = 1.0f;
            self.rightleg.opacity = 1.0f;
            self.body.opacity = 1.0f;
            self.leftleg.opacity = 1.0f;
            self.righthand.opacity = 1.0f;
            break;

        default:
            break;
    }
}



@end
