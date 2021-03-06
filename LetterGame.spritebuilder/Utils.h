//
//  Utils.h
//  LetterGame
//
//  Created by Xiaofen Liu on 3/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (CGFloat)getScreenWidth;
+ (CGFloat)getScreenHeight;
+ (NSString *)dateInFormat:(time_t)dateTime format:(NSString*) stringFormat;
+ (NSString *)transTime:(time_t)t;

@end
