//
//  HangmanModel.m
//  LetterGame
//
//  Created by Xiaofen Liu on 4/9/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "HangmanModel.h"

@implementation HangmanModel

+ (id)modelWithLevel{
    
    NSString *propertyListPath = [[NSBundle mainBundle] pathForResource:@"levelrandom" ofType:@"plist"];
    NSLog(@"listPath:%@", propertyListPath);
    
    NSDictionary* levelDict = [NSDictionary dictionaryWithContentsOfFile:propertyListPath];
    NSAssert(levelDict, @"level file not found");
    
    HangmanModel * hangmanMode = [[HangmanModel alloc] init];
    hangmanMode.pointPerTile = [levelDict[@"pointsPerTile"] intValue];
    hangmanMode.anagramPairs = levelDict[@"anagrams"];
    
    return hangmanMode;
}


@end
