//
//  ProjectFactory.h
//  CodeEditor
//
//  Created by yangzexin on 2/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProjectManager;

@interface ProjectManagerFactory : NSObject

+ (id<ProjectManager>)defaultProjectManager;

@end
