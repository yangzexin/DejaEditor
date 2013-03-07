//
//  DESimpleColorfulTextView.m
//  DejaEditor
//
//  Created by yangzexin on 13-3-7.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "DESimpleColorfulTextView.h"
#import "NSAttributedString+TextColor.h"
#import "DEColorfulTextView.h"
#import "NSString+JavaLikeStringHandle.h"

@implementation DESimpleColorfulTextView

- (void)dealloc
{
    self.keywordList = nil;
    self.textWillResetBlock = nil;
    self.textDidResetBlock = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    [super setText:nil];
    self.font = nil;
    self.textColor = nil;
    self.textAlignment = NSTextAlignmentLeft;
    
    self.keywordList = @[@"function",
                         @"self",
                         @"retain",
                         @"super",
                         @"if",
                         @"else",
                         @"elseif",
                         @"end",
                         @"local",
                         @"nil",
                         @"for",
                         @"and",
                         @"or",
                         @"not",
                         @"true",
                         @"false",
                         @"return",
                         @"math",
                         @"runtime",
                         @"class",
                         @"require ",
                         @",",
                         @";",
                         @"="
                         ];
    
    return self;
}

- (void)setText:(NSString *)text
{
    if(self.textWillResetBlock){
        self.textWillResetBlock();
    }
    [super setText:text];
    NSMutableAttributedString *tmpAttributedString = [[[NSMutableAttributedString alloc] initWithString:text] autorelease];
    [tmpAttributedString setColor:[UIColor colorWithRed:223.f/255.f green:63.f/255.f blue:178.f/255.f alpha:1] words:self.keywordList inText:tmpAttributedString decideBlock:^BOOL(NSString *word, NSRange range) {
        return [DEColorfulTextView isStandonlyWord:word inText:text range:range];
    }];
    NSInteger beginIndex = 0;
    NSInteger endIndex = 0;
    UIColor *stringColor = [UIColor colorWithRed:203.f/255.f green:46.0/255.f blue:31.f/255.f alpha:1];
    while((beginIndex = [text find:@"\"" fromIndex:endIndex]) != -1){
        endIndex = [text find:@"\"" fromIndex:beginIndex + 1];
        if(endIndex != -1){
            NSRange range = NSMakeRange(beginIndex, ++endIndex - beginIndex);
            [tmpAttributedString setTextColor:stringColor range:range];
        }else{
            break;
        }
    }
    beginIndex = 0;
    endIndex = 0;
    UIColor *commentColor = [UIColor colorWithRed:0 green:100.0/255.f blue:0 alpha:1];
    while((beginIndex = [text find:@"--" fromIndex:endIndex]) != -1){
        endIndex = [text find:@"\n" fromIndex:beginIndex];
        if(endIndex == -1){
            [tmpAttributedString setTextColor:commentColor range:NSMakeRange(beginIndex, text.length - beginIndex)];
            break;
        }else{
            [tmpAttributedString setTextColor:commentColor range:NSMakeRange(beginIndex, endIndex - beginIndex)];
        }
    }
    beginIndex = 0;
    endIndex = 0;
    while((beginIndex = [text find:@"--[[" fromIndex:endIndex]) != -1){
        endIndex = [text find:@"]]" fromIndex:beginIndex];
        if(endIndex == -1){
            [tmpAttributedString setTextColor:commentColor range:NSMakeRange(beginIndex, text.length - beginIndex)];
            break;
        }else{
            [tmpAttributedString setTextColor:commentColor range:NSMakeRange(beginIndex, endIndex - beginIndex)];
        }
    }
    self.attributedText = tmpAttributedString;
    if(self.textDidResetBlock){
        self.textDidResetBlock();
    }
}

@end
