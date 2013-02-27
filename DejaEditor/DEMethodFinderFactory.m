//
//  MethodFinderFactory.m
//  CodeEditor
//
//  Created by yangzexin on 13-2-21.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "DEMethodFinderFactory.h"
#import "DEArrayMethodFinder.h"

@implementation DEMethodFinderFactory

+ (id<DEMethodFinder>)methodFinderWithProject:(id<DEProject>)project scriptName:(NSString *)scriptName
{
    return [[[DEArrayMethodFinder alloc] initWithProject:project scriptName:scriptName] autorelease];
}

@end
