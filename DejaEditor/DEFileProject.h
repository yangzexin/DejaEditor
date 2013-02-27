//
//  CommonProject.h
//  CodeEditor
//
//  Created by yangzexin on 2/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DEProject.h"

@protocol DEProjectManager;

@interface DEFileProject : NSObject <DEProject>

@property(nonatomic, retain)id<DEProjectManager> projectManager;
- (id)initWithName:(NSString *)name projectPath:(NSString *)projectPath;

@end
