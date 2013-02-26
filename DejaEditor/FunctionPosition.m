//
//  FunctionPosition.m
//  CodeEditor
//
//  Created by yangzexin on 2/25/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "FunctionPosition.h"

@implementation FunctionPosition

+ (id)createWithFunctionName:(NSString *)functionName location:(NSInteger)location
{
    FunctionPosition *tmp = [[FunctionPosition new] autorelease];
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
