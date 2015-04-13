//
//  Utils.m
//  LetterGame
//
//  Created by Xiaofen Liu on 3/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (CGFloat)getScreenWidth{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    return fmin(screenSize.width, screenSize.height);
}

+ (CGFloat)getScreenHeight{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    return fmax(screenSize.width, screenSize.height);
}

+ (NSString *)dateInFormat:(time_t)dateTime format:(NSString*) stringFormat

{
    
    char buffer[80];
    
    const char *format = [stringFormat UTF8String];
    
    struct tm * timeinfo;
    
    timeinfo = localtime(&dateTime);
    
    strftime(buffer, 80, format, timeinfo);
    
    return [NSString  stringWithCString:buffer encoding:NSUTF8StringEncoding];
    
}

+ (NSString *)transTime:(time_t)t{
    NSString  *format = @"%M:%S";
    NSString  *time = [Utils dateInFormat:t format:format];
    return time;
}

@end
