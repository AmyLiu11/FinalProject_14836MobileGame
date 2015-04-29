//
//  AlertView.m
//  LetterGame
//
//  Created by Xiaofen Liu on 4/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "AlertView.h"
#import "Utils.h"

@implementation AlertView

- (void)didLoadFromCCB{
    CGFloat screenWidth = [Utils getScreenWidth];
    CGFloat screenHeight = [Utils getScreenHeight];
    
    CGPoint alertPos = CGPointMake(screenWidth/2, screenHeight/2);
    self.position = alertPos;
//    self.btn1 = [CCButton ]
}

- (void)onEnter{
    [super onEnter];
}


@end
