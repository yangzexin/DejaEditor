//
//  ProjectFactory.m
//  CodeEditor
//
//  Created by yangzexin on 2/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "ProjectManagerFactory.h"
#import "CommonFileProject.h"
#import "CommonFileProjectManager.h"

@implementation ProjectManagerFactory

+ (id<ProjectManager>)defaultProjectManager
{
    return [[CommonFileProjectManager new] autorelease];
}

@end
