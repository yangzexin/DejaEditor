//
//  NSAttributedString+TextColor.h
//  DejaEditor
//
//  Created by yangzexin on 13-3-7.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (TextColor)

- (NSMutableAttributedString*)setColor:(UIColor*)color
                                 words:(NSArray*)words
                                inText:(NSMutableAttributedString*)mutableAttributedString
                           decideBlock:(BOOL(^)(NSString *word, NSRange range))decideBlock;
- (void)setTextColor:(UIColor *)color range:(NSRange)range;

@end
