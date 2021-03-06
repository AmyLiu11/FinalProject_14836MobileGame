//
//  LetterView.h
//  LetterGame
//
//  Created by Xiaofen Liu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"
@class LetterView;

@protocol LetterDragDelegationProtocol <NSObject>

- (void)letterView:(LetterView *)letterView didDragToPoint:(CGPoint)point;

@end

@interface LetterView : CCSprite 
@property (weak, nonatomic) id<LetterDragDelegationProtocol> dragDelegate;
@property (strong,nonatomic) NSString * letter;
@property (assign,nonatomic) BOOL isMatched;

-(instancetype)initWithLetter:(NSString*)letter andPosition:(CGPoint)position andScale:(float)scale;
-(void)randomize;

@end
