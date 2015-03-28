//
//  LetterBox.m
//  LetterGame
//
//  Created by Xiaofen Liu on 2/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LetterBox.h"
#import "LGDefines.h"

@implementation LetterBox

-(instancetype)initWithPosition:(CGPoint)position withLetter:(NSString *)letter{
    self = [super initWithImageNamed:@"LetterGameAssets/slot.png"];
    if (self != nil) {
        float scaleSize = LETTER_SCALESIZE;
        self.scale = scaleSize;
        self.letter = letter;
        self.position = position;
    }
    return self;
}

@end
