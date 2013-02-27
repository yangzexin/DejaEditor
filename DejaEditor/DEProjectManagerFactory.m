//
//  ProjectFactory.m
//  CodeEditor
//
//  Created by yangzexin on 2/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "DEProjectManagerFactory.h"
#import "DEFileProject.h"
#import "DEFileProjectManager.h"

@implementation DEProjectManagerFactory

+ (id<DEProjectManager>)defaultProjectManager
{
    return [[DEFileProjectManager new] autorelease];
}

@end
