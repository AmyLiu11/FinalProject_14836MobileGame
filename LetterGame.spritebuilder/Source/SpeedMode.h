//
//  SpeedMode.h
//  LetterGame
//
//  Created by Xiaofen Liu on 3/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "LetterBoard.h"
#import "LevelModel.h"


@interface SpeedMode : CCNode<LetterBoardDelegationProtocol>
@property (nonatomic, strong) NSString * level;
@property (nonatomic, assign) NSUInteger totalScore;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) LevelModel * speedModel;

@end
