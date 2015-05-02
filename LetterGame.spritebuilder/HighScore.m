//
//  HighScore.m
//  LetterGame
//
//  Created by Xiaofen Liu on 4/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "HighScore.h"
#import "LGDefines.h"
#import "Utils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@implementation HighScore{
    CCButton * _backbtn;
    CCLabelTTF *_speedscore;
    CCLabelTTF *_hangmanscore;
    CCSprite * _facebook;
}

- (void)onEnter{
    [super onEnter];
    
    CCButton * invibtn = [CCButton buttonWithTitle:@"cg"];
    [_backbtn addChild:invibtn];
    invibtn.position = CGPointMake(22, 24);
    [invibtn setTarget:self selector:@selector(goBack)];
    [invibtn setColorRGBA:[CCColor clearColor]];
    [invibtn setBackgroundColor:[CCColor clearColor] forState:CCControlStateNormal];
    [invibtn setBackgroundColor:[CCColor clearColor] forState:CCControlStateSelected];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber * hscore = [userDefaults objectForKey:H_HIGH_SCORE];
    NSNumber * sscore = [userDefaults objectForKey:S_HIGH_SCORE];
    _speedscore.string = [NSString stringWithFormat:@"%lu", (unsigned long)sscore.integerValue];
    _hangmanscore.string = [NSString stringWithFormat:@"%lu", (unsigned long)hscore.integerValue];
    
    _facebook.userInteractionEnabled = YES;
    self.userInteractionEnabled = YES;

}


- (void)goBack{
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"MainScene"]];
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint pt = [touch locationInNode:self.parent];
    if (CGRectContainsPoint(_facebook.boundingBox, pt)) {
        CCLOG(@"touch facebook");
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:@"https://hunt.makeschool.com/posts/107"];
        int highscore = _speedscore.string.intValue > _hangmanscore.string.intValue ? _speedscore.string.intValue : _hangmanscore.string.intValue;
        content.contentTitle = [NSString stringWithFormat:@"I just got %d in Letter Game!", highscore];
        content.imageURL = [NSURL URLWithString:@"http://www.gotoandplay.it/_games/_lettersGame/lettersGame.jpg"];
        
        [FBSDKShareDialog showFromViewController:[CCDirector sharedDirector]
                                     withContent:content
                                        delegate:nil];
    }
}

@end
