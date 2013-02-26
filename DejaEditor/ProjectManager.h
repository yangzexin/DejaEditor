//
//  ProjectManager.h
//  CodeEditor
//
//  Created by yangzexin on 2/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Project;

@protocol ProjectManager <NSObject>

- (BOOL)projectExistsWithName:(NSString *)name;
- (void)removeProjectWithName:(NSString *)name;
- (void)renameProjectWithName:(NSString *)name newName:(NSString *)newName;
- (id<Project>)projectWithName:(NSString *)name;
- (NSArray *)projectNameList;

@end
