//
//  LetterBoard.m
//  LetterGame
//
//  Created by Xiaofen Liu on 4/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "LetterBoard.h"
#import "LGDefines.h"
#import "Utils.h"
#import "SpeedMode.h"
#import "HangmanMode.h"
#import "cocos2d.h"

@interface LetterBoard()

@property (nonatomic, strong) NSMutableArray * boxArray;
@property (nonatomic, strong) NSMutableArray * letterArray;
@property (nonatomic, assign) CGFloat lastLetterYPos;
@property (nonatomic, assign) BOOL hasMoreWords;
@property (nonatomic, assign) CGFloat comboletterLength;
@property (nonatomic, strong) NSString * beforeString;
@property (nonatomic, strong) NSMutableString * completeString;
@property (nonatomic, strong) NSString * afterString;
@property (nonatomic, assign) NSUInteger wordCount;
@property (nonatomic, assign) CGFloat x_padding;
@property (nonatomic, strong) NSString * fixedString;
@property (nonatomic, strong) CCActionSoundEffect * wrongSound;
@property (nonatomic, strong) CCActionSoundEffect * rightSound;
@property (nonatomic, strong) CCActionSoundEffect * successFinishSound;
@property (nonatomic, assign) BOOL isSeekHints;

@end

@implementation LetterBoard

- (id)initWithBeforeWord:(NSString*)bw afterW:(NSString*)aw withCount:(NSUInteger)c{
    self = [super init];
    if (self) {
        self.boxArray = [NSMutableArray array];
        self.letterArray = [NSMutableArray array];
        self.completeString = [NSMutableString string];
        self.beforeString = bw;
        self.afterString = aw;
        self.fixedString = [self.afterString stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.wordCount = c;
        self.isSeekHints = NO;
        self.x_padding = LETTERBOX_X_GAP;
        [self setupLetters];
        [self setupLetterBox];
    }
    return self;
}

- (void)preloadSoundEffect{
    NSString * rsoundPath = [[NSBundle mainBundle] pathForResource:@"ding" ofType:@"mp3"];
    NSString * wsoundPath = [[NSBundle mainBundle] pathForResource:@"error" ofType:@"wav"];
    NSString * winsoundPath = [[NSBundle mainBundle] pathForResource:@"win" ofType:@"mp3"];
    self.rightSound = [CCActionSoundEffect actionWithSoundFile:rsoundPath pitch:1.0f pan:0 gain:1.0f];
    self.wrongSound = [CCActionSoundEffect actionWithSoundFile:wsoundPath pitch:1.0f pan:0 gain:1.0f];
    self.successFinishSound = [CCActionSoundEffect actionWithSoundFile:winsoundPath pitch:1.0f pan:0 gain:1.0f];
}

- (void)setupLetters{
    NSArray * wordArr = [self.beforeString componentsSeparatedByString:@" "];
    if (wordArr.count > 0) {
        self.hasMoreWords = YES;
    }else{
        self.hasMoreWords  = NO;
    }
    
    self.lastLetterYPos = LETTER_INITIAL_Y;
    self.x_padding = LETTERBOX_X_GAP;
    if (!self.hasMoreWords) {
        self.comboletterLength = [self calculateLetterLength:self.beforeString];
        CGFloat lastX = self.x_padding + self.comboletterLength / 2.0f;
        NSMutableArray * tempArr = [self splitWord:self.beforeString];
        for (int i = 0 ; i < (int)self.beforeString.length; i++) {
            NSString * lette = [tempArr objectAtIndex:i];
            CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
            LetterView * letter = [[LetterView alloc] initWithLetter:lette andPosition:worldPoint  andScale:(self.comboletterLength / (LETTER_LENGTH))];
            letter.dragDelegate = self;
            [letter randomize];
            lastX += (self.comboletterLength + LETTERBOX_BETWEEN_GAP);
            [self addChild:letter];
            [self.letterArray addObject:letter];
        }
    }else{
        CGFloat beforeletterLength = [self calculateLetterLength:self.beforeString];
        CGFloat afterletterLength = [self calculateLetterLength:self.afterString];
        self.comboletterLength = beforeletterLength < afterletterLength ? beforeletterLength : afterletterLength;
        CGFloat lastX = self.x_padding + self.comboletterLength / 2.0f;
        for (int j = 0; j < (int)wordArr.count; j++) {
            NSString * str = [wordArr objectAtIndex:j];
            NSMutableArray * temArr = [self splitWord:str];
            if (j > 0) {
                lastX = self.x_padding;
                self.lastLetterYPos -= (LETTERBOX_Y_GAP + self.comboletterLength);
            }
            for (int i = 0 ; i < (int)str.length; i++) {
                CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
                LetterView * letter = [[LetterView alloc] initWithLetter:[temArr objectAtIndex:i] andPosition:worldPoint andScale:(self.comboletterLength / (LETTER_LENGTH))];
                letter.dragDelegate = self;
                [letter randomize];
                lastX += (self.comboletterLength + LETTERBOX_BETWEEN_GAP);
                [self addChild:letter];
                [self.letterArray addObject:letter];
            }
        }
    }
}

- (void)setupLetterBox{
    NSArray * wordArr = [self.afterString componentsSeparatedByString:@" "];
    self.lastLetterYPos -= LETTER_BOX_GAP;
    self.x_padding = LETTERBOX_X_GAP;
    
    if (!self.hasMoreWords) {
        CGFloat letterBoxLength = [self calculateLetterLength:self.afterString];
        CGFloat lastX = self.x_padding + letterBoxLength / 2.0f;
        NSMutableArray * tempArr = [self splitWord:self.afterString];
        for (int i = 0 ; i < (int)self.afterString.length ; i++){
            NSString * str = [tempArr objectAtIndex:i];
            CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
            LetterBox * box = [[LetterBox alloc] initWithPosition:worldPoint withLetter:str withScale:(letterBoxLength / (LETTER_LENGTH))];
            box.letter = str;
            box.isMatched = NO;
            lastX += (letterBoxLength + LETTERBOX_BETWEEN_GAP);
            [self addChild:box];
            [self.boxArray addObject:box];
        }
    }else{
        CGFloat lastX = self.x_padding + self.comboletterLength / 2.0f;
        for (int j = 0; j < (int)wordArr.count; j++) {
            NSString * str = [wordArr objectAtIndex:j];
            NSMutableArray * temArr = [self splitWord:str];
            if (j > 0) {
                lastX = self.x_padding + self.comboletterLength / 2.0f;
                self.lastLetterYPos -= (LETTERBOX_Y_GAP + self.comboletterLength);
            }
            for (int i = 0 ; i < (int)str.length; i++) {
                NSString * lette = [temArr objectAtIndex:i];
                CGPoint worldPoint = ccp(lastX, self.lastLetterYPos);
                LetterBox * box = [[LetterBox alloc] initWithPosition:worldPoint withLetter:lette withScale:(self.comboletterLength / (LETTER_LENGTH ))];
                box.isMatched = NO;
                lastX += (self.comboletterLength + LETTERBOX_BETWEEN_GAP);
                [self addChild:box];
                [self.boxArray addObject:box];
            }
        }
    }
}


- (NSMutableArray*)splitWord:(NSString*)string{
    NSMutableArray * letterArr = [NSMutableArray array];
    if ([string length] == 0) {
        return letterArr;
    }
    [string enumerateSubstringsInRange:[string rangeOfString:string] options:NSStringEnumerationByComposedCharacterSequences usingBlock: ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
        [letterArr addObject:substring];
    }];
    
    return letterArr;
}

- (CGFloat)calculateLetterLength : (NSString *)str{
    NSArray * wordArr = [str componentsSeparatedByString:@" "];
    NSMutableArray * tempArr = [self splitWord:str];
    CGFloat screenWidth = [Utils getScreenWidth];
    
    if (wordArr.count > 1) {
        CGFloat maxLength = 0.0f;
        for (NSString * str in wordArr){
            maxLength = maxLength > str.length ? maxLength : str.length;
        }
        if (maxLength > MAXIMUM_CHARCTER_IN_A_LINE) {
            self.x_padding = LETTERBOX_X_GAP - 10;
        }
        return ((screenWidth - self.x_padding * 2 - LETTERBOX_BETWEEN_GAP * (maxLength - 1)) / maxLength);
    }else {
        if ([str length] > MAXIMUM_CHARCTER_IN_A_LINE) {
            self.x_padding = LETTERBOX_X_GAP - 10;
        }
        return ((screenWidth - self.x_padding * 2 - LETTERBOX_BETWEEN_GAP * (tempArr.count - 1)) / tempArr.count);
    }
}

- (void)letterView:(LetterView *)letterView didDragToPoint:(CGPoint)point{
    LetterBox * targetView = nil;
    
    for (LetterBox* box in self.boxArray) {
        
        if (CGRectContainsPoint(box.boundingBox, point)) {
            targetView = box;
            break;
        }
    }
    
    if (targetView!=nil) {
        
        //2 check if letter matches
        if ([targetView.letter isEqualToString: letterView.letter]) {
            self.isSeekHints = NO;
            targetView.isMatched = YES;
            letterView.isMatched = YES;
            NSUInteger points = 0;
            if ([self.delegate isKindOfClass:[SpeedMode class]]) {
                SpeedMode * mode = (SpeedMode*)self.delegate;
                points = mode.pointsPerTile;
            }else{
                HangmanMode * mode = (HangmanMode*)self.delegate;
                points = mode.pointsPerTile;
            }
            
            [self showPointsAnimation:targetView.position withPoint:points];
            [self addPoints];
            [self.completeString appendString:letterView.letter];
            [self placeLetter:letterView atTarget:targetView];
            if ([self.completeString isEqualToString:self.fixedString]) {
                [self playSuccessSpellingSound];
                [self proceedNextStepWhenFinishSpellingOneWord];
            }
        } else {
            if ([self.delegate isKindOfClass:[SpeedMode class]]) {
                 [self showWrongLetterAnimation];
            }else{
                HangmanMode * mode = (HangmanMode*)self.delegate;
                if (targetView.isMatched == YES) {
                    return;
                }
                [self showWrongLetterAnimation];
                [mode showHangmanWithlb:self];
            }
        }
    }
}

-(void)addPoints{
    if ([self.delegate isKindOfClass:[SpeedMode class]]) {
        SpeedMode * mode = (SpeedMode*)self.delegate;
        mode.totalScore += mode.pointsPerTile;
    }else{
        HangmanMode * mode = (HangmanMode*)self.delegate;
        mode.totalScore += mode.pointsPerTile;
    }
}


-(void)proceedNextStepWhenFinishSpellingOneWord{
    if ([self.delegate isKindOfClass:[SpeedMode class]]) {
        SpeedMode * mode = (SpeedMode*)self.delegate;
        if (mode.index == (mode.speedModel.anagramPairs.count - 1)) {
            if ([mode.currentScene isEqualToString:@"hard"]) {
                [self.delegate finishSpeedModeWithlb:self];
            }else{
                [self.delegate enterNextLevelWithlb:self];
            }
        }else{
            [self.delegate didFinishOneAnagram:self];
        }
    }else{
        HangmanMode * mode = (HangmanMode*)self.delegate;
        if (mode.index == (mode.model.anagramPairs.count - 1)) {
            [self.delegate finishSpeedModeWithlb:self];
        }else{
            [self.delegate didFinishOneAnagram:self];
        }
    }
}

-(void)playSuccessSpellingSound{
    [self runAction:self.successFinishSound];
}

-(void)placeLetter:(LetterView*)lView atTarget:(LetterBox*)targetView
{
    lView.userInteractionEnabled = FALSE;
    
    [UIView animateWithDuration:0.35
                          delay:0.00
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         lView.position = targetView.position;
                         lView.rotation = 0.0f;
                     }
                     completion:^(BOOL finished){
                         targetView.visible = NO;
                     }];
    
}

- (void)showWrongLetterAnimation{
    CGFloat screenWidth = [Utils getScreenWidth];
    CGFloat screenHeight = [Utils getScreenHeight];
    CCLabelTTF * wrongLabel = [[CCLabelTTF alloc] initWithString:@"Wrong Letter" fontName:@"Arial-BoldMT" fontSize:50];
    wrongLabel.fontColor = [CCColor redColor];
    wrongLabel.anchorPoint = CGPointMake(0.5f, 0.5f);
    wrongLabel.position = CGPointMake(screenWidth/2.0f, screenHeight/2.0f);
    [self addChild:wrongLabel];
    wrongLabel.opacity = 0.0f;
    
    id fadeInAction = [CCActionFadeTo actionWithDuration:0.7f opacity:1.0f];
    id moveAction = [CCActionMoveTo actionWithDuration:0.7f position:ccpAdd(wrongLabel.position, CGPointMake(0, -30))];
    id fadeOutAction = [CCActionFadeTo actionWithDuration:0.2f opacity:0.0f];
    id combinedAction = [CCActionSpawn actionOne:fadeInAction two:moveAction];
    id removeAction = [CCActionRemove action];
    [wrongLabel runAction: [CCActionSequence actions: self.wrongSound,combinedAction, fadeOutAction,removeAction,nil]];
}

- (void)showPointsAnimation:(CGPoint)effectPoint withPoint:(NSUInteger)points{
    CGFloat screenWidth = [Utils getScreenWidth];
    CGFloat screenHeight = [Utils getScreenHeight];
    CCLabelTTF * pointsLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"+%lu",(unsigned long)points] fontName:@"Arial-BoldMT" fontSize:50];
    pointsLabel.fontColor = [CCColor greenColor];
    pointsLabel.anchorPoint = CGPointMake(0.5f, 0.5f);
    pointsLabel.position = CGPointMake(screenWidth/2.0f, screenHeight/2.0f);
    [self addChild:pointsLabel];
    pointsLabel.opacity = 0.0f;
    
    id fadeInAction = [CCActionFadeTo actionWithDuration:0.7f opacity:1.0f];
    id moveAction = [CCActionMoveTo actionWithDuration:0.7f position:CGPointMake(260.0f, 507.0f)];
    id fadeOutAction = [CCActionFadeTo actionWithDuration:0.2f opacity:0.0f];
    id combinedAction = [CCActionSpawn actionOne:fadeInAction two:moveAction];
    id removeAction = [CCActionRemove action];
    
    [pointsLabel runAction: [CCActionSequence actions: self.rightSound,combinedAction,fadeOutAction,removeAction,nil]];
    
    if (!self.isSeekHints) {
        CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"WinParticle"];
        explosion.autoRemoveOnFinish = TRUE;
        explosion.position = effectPoint;
        [self addChild:explosion];
    }
}

- (void)resetBoardWithbw:(NSString*)bw afterW:(NSString*)af{
    [self removeAllChildrenWithCleanup:YES];
    self.beforeString = bw;
    self.afterString = af;
    self.fixedString = [self.afterString stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self.completeString setString:@""];
    [self.boxArray removeAllObjects];
    self.comboletterLength = 0.0f;
    [self setupLetters];
    [self setupLetterBox];
}


- (void)findFirstUnmatchedBox{
    self.isSeekHints = YES;
    LetterBox * unmatchedBox = nil;
    for (LetterBox* box in self.boxArray) {
        
        if (box.isMatched == NO) {
            unmatchedBox = box;
            break;
        }
    }
    
    LetterView * tile = nil;
    for (LetterView * t in self.letterArray) {
        if ( t.isMatched == NO && [t.letter isEqualToString:unmatchedBox.letter]) {
            tile = t;
            break;
        }
    }
    
    if (tile == nil && unmatchedBox == nil) {
        [self proceedNextStepWhenFinishSpellingOneWord];
        return;
    }
    
    tile.isMatched = YES;
    unmatchedBox.isMatched = YES;
    
    id moveAction = [CCActionMoveTo actionWithDuration:0.7f position:unmatchedBox.position];
    id fadeOutAction = [CCActionFadeTo actionWithDuration:0.2f opacity:0.0f];
    [tile runAction: moveAction];
    tile.rotation = 0.0f;
    [unmatchedBox runAction: [CCActionSequence actions: [CCActionDelay actionWithDuration:0.7],fadeOutAction,nil]];
    
    [self.completeString appendString:tile.letter];
    if ([self.completeString isEqualToString:self.fixedString]) {
        [self playSuccessSpellingSound];
        [self proceedNextStepWhenFinishSpellingOneWord];
    }
}





@end
