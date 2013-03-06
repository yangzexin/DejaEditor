//
//  ColorfulTextView.m
//  DejaEditor
//
//  Created by yangzexin on 3/6/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "DEColorfulTextView.h"
#import "SVCommonUtils.h"

@interface DEColorfulTextView ()

@property(nonatomic, copy)NSArray *keywordList;

@end

@implementation DEColorfulTextView

- (void)dealloc
{
    self.attributedTextBlock = nil;
    self.keywordList = nil;
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
                         @"require "
                         ];
    
    return self;
}

+ (NSMutableAttributedString*)setColor:(UIColor*)color words:(NSArray*)words inText:(NSMutableAttributedString*)mutableAttributedString decideBlock:(BOOL(^)(NSString *word, NSRange range))decideBlock
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

+ (BOOL)isStandonlyWord:(NSString *)word inText:(NSString *)text range:(NSRange )range
{
    BOOL isPrechAlphat = NO;
    if(range.location != 0){
        unichar prech = [text characterAtIndex:range.location - 1];
        isPrechAlphat = [SVCommonUtils isAlphbelt:prech];
    }
    BOOL isSufchAlphbelt = NO;
    if(range.location + word.length < text.length){
        unichar sufch = [text characterAtIndex:range.location + word.length];
        isSufchAlphbelt = [SVCommonUtils isAlphbelt:sufch];
    }
    return !isPrechAlphat && !isSufchAlphbelt;
}

- (void)updateColor
{
    NSString *text = self.text;
    NSMutableAttributedString *content = [self.class setColor:[UIColor colorWithRed:223.f/255.f green:63.f/255.f blue:178.f/255.f alpha:1] words:self.keywordList inText:[[[NSMutableAttributedString alloc] initWithString:text] autorelease] decideBlock:^BOOL(NSString *word, NSRange range) {
        return [self.class isStandonlyWord:word inText:text range:range];
    }];
    self.attributedText = content;
    if(self.attributedTextBlock){
        self.attributedText = self.attributedTextBlock(content, text);
    }
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self updateColor];
}

@end

