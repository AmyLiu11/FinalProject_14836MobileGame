//
//  Hangman.h
//  LetterGame
//
//  Created by Xiaofen Liu on 4/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Hangman : CCSprite

- (Hangman*)getHangmanWithStep:(NSUInteger)step;

@end
