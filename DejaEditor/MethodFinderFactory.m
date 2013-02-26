//
//  MethodFinderFactory.m
//  CodeEditor
//
//  Created by yangzexin on 13-2-21.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "MethodFinderFactory.h"
#import "ArrayMethodFinder.h"

@implementation MethodFinderFactory

+ (id<MethodFinder>)methodFinderWithProject:(id<Project>)project scriptName:(NSString *)scriptName
{
    return [[[ArrayMethodFinder alloc] initWithProject:project scriptName:scriptName] autorelease];
}

@end
