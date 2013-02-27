//
//  StringPosition.m
//  CodeEditor
//
//  Created by yangzexin on 2/24/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "DEStringPosition.h"

@implementation DEStringPosition

- (void)dealloc
{
    self.string = nil;
    [super dealloc];
}

+ (id)createWithPosition:(NSInteger)position string:(NSString *)string
{
    DEStringPosition *sp = [[DEStringPosition new] autorelease];
    sp.position = position;
    sp.string = string;
    
    return sp;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%d, %@", self.position, self.string];
}

@end
