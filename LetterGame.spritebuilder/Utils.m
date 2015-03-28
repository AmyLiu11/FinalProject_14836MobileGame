//
//  Utils.m
//  LetterGame
//
//  Created by Xiaofen Liu on 3/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (CGFloat)getScreenWidth{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    return fmin(screenSize.width, screenSize.height);
}

+ (CGFloat)getScreenHeight{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    return fmax(screenSize.width, screenSize.height);
}

@end
