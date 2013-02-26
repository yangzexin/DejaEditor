//
//  CommonProject.h
//  CodeEditor
//
//  Created by yangzexin on 2/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Project.h"

@protocol ProjectManager;

@interface CommonFileProject : NSObject <Project>

@property(nonatomic, retain)id<ProjectManager> projectManager;
- (id)initWithName:(NSString *)name projectPath:(NSString *)projectPath;

@end
