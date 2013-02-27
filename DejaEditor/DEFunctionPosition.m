//
//  FunctionPosition.m
//  CodeEditor
//
//  Created by yangzexin on 2/25/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "DEFunctionPosition.h"

@implementation DEFunctionPosition

+ (id)createWithFunctionName:(NSString *)functionName location:(NSInteger)location
{
    DEFunctionPosition *tmp = [[DEFunctionPosition new] autorelease];
    tmp.functionName = functionName;
    tmp.location = location;
    return tmp;
}

- (void)dealloc
{
    self.functionName = nil;
    [super dealloc];
}

@end
