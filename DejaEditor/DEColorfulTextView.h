//
//  ColorfulTextView.h
//  DejaEditor
//
//  Created by yangzexin on 3/6/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DEColorfulTextView : UITextView

@property(nonatomic, copy)NSAttributedString *(^attributedTextBlock)(NSMutableAttributedString *attributedText, NSString *originalText);
+ (NSMutableAttributedString*)setColor:(UIColor*)color words:(NSArray*)words inText:(NSMutableAttributedString*)mutableAttributedString decideBlock:(BOOL(^)(NSString *word, NSRange range))decideBlock;
+ (BOOL)isStandonlyWord:(NSString *)word inText:(NSString *)text range:(NSRange )range;
- (void)updateColor;

@end
