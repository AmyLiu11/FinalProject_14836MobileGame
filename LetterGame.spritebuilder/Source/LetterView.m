//
//  LetterView.m
//  LetterGame
//
//  Created by Xiaofen Liu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LetterView.h"

@implementation LetterView{
    int _xOffset;
    int _yOffset;
}


-(id)initWithLetter:(NSString*)letter andPosition:(CGPoint)position{
    self = [super initWithImageNamed:@"LetterGameAssets/tile.png"];
    if(self != nil){
        float scaleSize = 0.5f;
        self.scale = scaleSize;
        self.position = position;
        self.letter = letter;
        CGSize letterViewSize = self.contentSize;
        
        //add a letter on top
        CCLabelTTF * letterlabel = [CCLabelTTF labelWithString:letter fontName:@"Verdana-Bold" fontSize:200.0*scaleSize];
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

@end
