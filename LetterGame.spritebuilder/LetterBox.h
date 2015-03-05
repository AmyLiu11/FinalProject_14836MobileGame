//
//  LetterBox.h
//  LetterGame
//
//  Created by Xiaofen Liu on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface LetterBox : CCSprite
@property (strong,nonatomic) NSString * letter;

-(instancetype)initWithPosition:(CGPoint)position withLetter:(NSString *)letter;
@end
