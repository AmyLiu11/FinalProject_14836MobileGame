//
//  LetterView.m
//  LetterGame
//
//  Created by Xiaofen Liu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LetterView.h"
#import "LGDefines.h"
#include <math.h>

@implementation LetterView{
    int _xOffset;
    int _yOffset;
}


-(id)initWithLetter:(NSString*)letter andPosition:(CGPoint)position andScale:(float)scale{
    self = [super initWithImageNamed:@"LetterGameAssets/tile.png"];
    if(self != nil){
        self.scale = scale;
        NSLog(@"width %f, height %f", self.boundingBox.size.width, self.boundingBox.size.height);
        self.position = position;
        self.letter = letter;
        self.anchorPoint = CGPointMake(0.5f, 0.5f);
        CGSize letterViewSize = self.contentSize;
        
        //add a letter on top
        CCLabelTTF * letterlabel = [CCLabelTTF labelWithString:letter fontName:@"Verdana-Bold" fontSize:LETTER_SIZE*LETTER_SCALESIZE];
        letterlabel.position =  ccp(letterViewSize.width/2, letterViewSize.height/2);
        letterlabel.userInteractionEnabled = TRUE;
        [self addChild:letterlabel];
         self.userInteractionEnabled = TRUE;
    }
    return self;
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint pt = [touch locationInNode:self.parent];
    _xOffset = pt.x - self.position.x;
    _yOffset = pt.y - self.position.y;
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // whenever touches move, update the position of the mouseJointNode to the touch position
    CGPoint pt = [touch locationInNode:self.parent];
    self.position = CGPointMake(pt.x - _xOffset, pt.y - _yOffset);
}

-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    if (self.dragDelegate) {
        [self.dragDelegate letterView:self didDragToPoint:self.position];
    }
}

-(void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
  
}

-(void)randomize{
    //set random rotation of the tile
    //anywhere between -0.2 and 0.3 radians
    float rotation = ((arc4random() % 50) / (float)100 - 0.2) * LETTER_ROTATION;
    self.rotation = rotation;
    
    //2
    //move randomly upwards
    int yOffset = (arc4random() % 10) - 10;
    self.position = CGPointMake(self.position.x, self.position.y + yOffset);
}

@end
