//
//  LetterBoard.h
//  LetterGame
//
//  Created by Xiaofen Liu on 4/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "LetterView.h"
#import "LetterBox.h"

@class LetterBoard;

@protocol LetterBoardDelegationProtocol <NSObject>

@required
- (void)finishSpeedModeWithlb:(LetterBoard*)lb;
- (void)didFinishOneAnagram:(LetterBoard*)lb;

@optional
- (void)enterNextLevelWithlb:(LetterBoard*)lb;
- (void)showHangmanWithlb:(LetterBoard*)lb;

@end

@interface LetterBoard : CCNode<LetterDragDelegationProtocol>
@property (nonatomic, weak) id<LetterBoardDelegationProtocol> delegate;

- (id)initWithBeforeWord:(NSString*)bw afterW:(NSString*)aw withCount:(NSUInteger)c;
- (void)resetBoardWithbw:(NSString*)bw afterW:(NSString*)af;
- (void)preloadSoundEffect;
- (void)findFirstUnmatchedBox;

@end
