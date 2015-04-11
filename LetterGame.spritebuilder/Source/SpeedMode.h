//
//  SpeedMode.h
//  LetterGame
//
//  Created by Xiaofen Liu on 3/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "LevelModel.h"
#import "LetterView.h"

@interface SpeedMode : CCNode<LetterDragDelegationProtocol>
@property (nonatomic, strong) LevelModel * speedModel;


@end
