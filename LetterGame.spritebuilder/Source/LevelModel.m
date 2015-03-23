//
//  LevelModel.m
//  LetterGame
//
//  Created by Xiaofen Liu on 3/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LevelModel.h"

@implementation LevelModel

+ (id)modelWithLevel:(NSString*)level{
    NSString *propertyListPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"level%@",level] ofType:@"plist"];
    NSLog(@"listPath:%@", propertyListPath);
    
    NSDictionary* levelDict = [NSDictionary dictionaryWithContentsOfFile:propertyListPath];
    NSAssert(levelDict, @"level file not found");
    
    LevelModel * levelMode = [[LevelModel alloc] init];
    levelMode.pointPerTile = [levelDict[@"pointsPerTile"] intValue];
    levelMode.anagramPairs = levelDict[@"anagrams"];
    levelMode.timeToSolve = [levelDict[@"timeToSolve"] intValue];

    return levelMode;
}

@end
