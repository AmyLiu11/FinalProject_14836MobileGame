//
//  HangmanMode.h
//  LetterGame
//
//  Created by Xiaofen Liu on 3/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "LetterBoard.h"
#import "HangmanModel.h"
#import "LoseScene.h"

@interface HangmanMode : CCNode<LetterBoardDelegationProtocol>
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSUInteger totalScore;
@property (nonatomic, strong) HangmanModel * model;
@property (nonatomic, assign) NSInteger step;
@property (nonatomic, assign) NSUInteger pointsPerTile;


@end
