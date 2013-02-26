//
//  CommonProjectManager.h
//  CodeEditor
//
//  Created by yangzexin on 2/17/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProjectManager.h"

@interface CommonFileProjectManager : NSObject <ProjectManager>

+ (NSString *)projectsHomePath;

@end
