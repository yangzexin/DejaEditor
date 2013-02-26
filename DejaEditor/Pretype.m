//
//  Pretype.m
//  CodeEditor
//
//  Created by yangzexin on 2/21/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "Pretype.h"

@implementation Pretype

+ (id)createWithText:(NSString *)text
{
    return [[[self.class alloc] initWithText:text] autorelease];
}

+ (id)createWithText:(NSString *)text additionalText:(NSString *)additionalText
{
    Pretype *tmp = [self.class createWithText:text];
    tmp.additionalText = additionalText;
    return tmp;
}

- (void)dealloc
{
    [_text release];
    [_lowerText release];
    self.additionalText = nil;
    [super dealloc];
}

- (id)initWithText:(NSString *)text
{
    self = [super init];
    
    self.text = text;
    
    return self;
}

- (void)setText:(NSString *)text
{
    if(_text != text){
        [_text release];
        _text = [text copy];
        [_lowerText release];
        _lowerText = [[_text lowercaseString] copy];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@, %@", _lowerText, _text, _additionalText];
}

@end
