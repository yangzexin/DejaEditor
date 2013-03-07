//
//  NSAttributedString+TextColor.m
//  DejaEditor
//
//  Created by yangzexin on 13-3-7.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "NSAttributedString+TextColor.h"

@implementation NSMutableAttributedString (TextColor)

- (NSMutableAttributedString*)setColor:(UIColor*)color
                                 words:(NSArray*)words
                                inText:(NSMutableAttributedString*)mutableAttributedString
                           decideBlock:(BOOL(^)(NSString *word, NSRange range))decideBlock
{
    
    NSUInteger count = 0, length = [mutableAttributedString length];
    NSRange range = NSMakeRange(0, length);
    
    for (NSString *op in words) {
        count = 0, length = [mutableAttributedString length];
        range = NSMakeRange(0, length);
        while(range.location != NSNotFound){
            range = [[mutableAttributedString string] rangeOfString:op options:0 range:range];
            if(range.location != NSNotFound) {
                BOOL shouldSet = YES;
                if(decideBlock){
                    shouldSet = decideBlock(op, range);
                }
                if(shouldSet){
                    [mutableAttributedString setAttributes:@{NSForegroundColorAttributeName : color} range:NSMakeRange(range.location, [op length])];
                }
                range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                count++;
            }
        }
    }
    
    return mutableAttributedString;
}

- (void)setTextColor:(UIColor *)color range:(NSRange)range
{
    [self setAttributes:@{NSForegroundColorAttributeName : color} range:range];
}

@end
