//
//  ZipProjectManager.h
//  CodeEditor
//
//  Created by yangzexin on 13-2-19.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Project;

OBJC_EXPORT NSString *kPackageFileExtenstion;

@interface ZipProjectManager : NSObject

+ (NSArray *)zipProjectNameList;
+ (void)unzipProjectWithName:(NSString *)zipProjectName toDirectoryPath:(NSString *)toDirectoryPath;
+ (void)zipProject:(id<Project>)mainProject;
+ (void)packageProject:(id<Project>)mainProject;
+ (NSString *)importZipWithContentOfFile:(NSString *)filePath;
+ (void)removeZipProjecWithName:(NSString *)zipProjectName;
+ (void)renameZipProjectWithName:(NSString *)zipProjectName newName:(NSString *)newName;
+ (BOOL)zipProjectExistsWithName:(NSString *)projectName;

@end
