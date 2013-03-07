//
//  ColorfulTextView.m
//  DejaEditor
//
//  Created by yangzexin on 3/6/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "DEColorfulTextView.h"
#import "SVCommonUtils.h"
#import "SVTimeCostTracer.h"
#import "NSAttributedString+TextColor.h"

@interface DEColorfulTextView ()

@property(nonatomic, copy)NSArray *keywordList;
@property(nonatomic, assign)BOOL updatingColor;

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
    if(self.updatingColor){
        return;
    }
    self.updatingColor = YES;
    NSString *text = self.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SVTimeCostTracer markWithIdentifier:@"updateColorCost"];
        NSAttributedString *attributedText = nil;
        NSMutableAttributedString *content = [[[NSMutableAttributedString alloc] initWithString:text] autorelease];
        content = [content setColor:[UIColor colorWithRed:223.f/255.f green:63.f/255.f blue:178.f/255.f alpha:1]
                              words:self.keywordList
                             inText:[[[NSMutableAttributedString alloc] initWithString:text] autorelease]
                        decideBlock:^BOOL(NSString *word, NSRange range) {
                            return [self.class isStandonlyWord:word inText:text range:range];
                        }];
        if(self.attributedTextBlock){
            attributedText = self.attributedTextBlock(content, text);
        }else{
            attributedText = content;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSRange tmpRange = self.selectedRange;
            [super setText:self.text];
            self.attributedText = attributedText;
            if(self.isFirstResponder){
                self.selectedRange = NSMakeRange(tmpRange.location, 0);
                [self insertText:@" "];
                [self deleteBackward];
                self.selectedRange = tmpRange;
            }
            self.updatingColor = NO;
            [SVTimeCostTracer timeCostWithIdentifier:@"updateColorCost" print:YES];
        });
    });
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self updateColor];
}

@end

