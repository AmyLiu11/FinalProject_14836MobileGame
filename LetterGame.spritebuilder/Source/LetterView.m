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
#import <QuartzCore/QuartzCore.h>

@interface LetterView()

@property (nonatomic, assign) CGFloat scaleA;

@end

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
        [self addLetterOn:letterViewSize withLetter:letter];
        self.userInteractionEnabled = TRUE;
        
    }
    return self;
}

- (void)addLetterOn:(CGSize)size withLetter:(NSString*)string{
    //add a letter on top
    CCLabelTTF * letterlabel = [CCLabelTTF labelWithString:string fontName:@"Verdana-Bold" fontSize:LETTER_SIZE*LETTER_SCALESIZE];
    letterlabel.position =  ccp(size.width/2, size.height/2);
    letterlabel.userInteractionEnabled = TRUE;
    [self addChild:letterlabel];
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    //此处要增加当前view在最前面的逻辑
    self.scaleA = self.scale;
    [self removeAllChildren];
    self.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"LetterGameAssets/twshadow7.png"];
    
    CCLOG(@"contentSize w:%f h:%f", self.contentSize.width, self.contentSize.height);
    [self addLetterOn:self.contentSize withLetter:self.letter];
    self.scale = self.scale * 1.2;
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
    [self removeAllChildren];
    self.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"LetterGameAssets/tile.png"];
    [self addLetterOn:self.contentSize withLetter:self.letter];
    self.scale = self.scaleA;
    
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
