//
//  LevelModel.h
//  LetterGame
//
//  Created by Xiaofen Liu on 3/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LevelModel : NSObject
@property (assign, nonatomic) NSUInteger timeToSolve;
@property (assign, nonatomic) NSUInteger stepToSolve;
@property (assign, nonatomic) NSUInteger pointPerTile;
@property (strong, nonatomic) NSArray * anagramPairs;

+ (id)modelWithLevel:(NSString*)level;

@end
