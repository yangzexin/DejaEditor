//
//  CommonProjectManager.m
//  CodeEditor
//
//  Created by yangzexin on 2/17/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "DEFileProjectManager.h"
#import "DEFileProject.h"
#import "CommonUtils.h"

@implementation DEFileProjectManager

- (id<DEProject>)projectWithName:(NSString *)name
{
    NSString *projectPath = [[self.class projectsHomePath] stringByAppendingPathComponent:name];
    DEFileProject *fileProject = [[[DEFileProject alloc] initWithName:name
                                                                  projectPath:projectPath] autorelease];
    fileProject.projectManager = self;
    return fileProject;
}

- (BOOL)projectExistsWithName:(NSString *)name
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[[self.class projectsHomePath] stringByAppendingPathComponent:name]];
}

- (void)removeProjectWithName:(NSString *)name
{
    [[NSFileManager defaultManager] removeItemAtPath:[[self.class projectsHomePath] stringByAppendingPathComponent:name] error:nil];
}

- (void)renameProjectWithName:(NSString *)name newName:(NSString *)newName
{
    NSString *filePath = [[self.class projectsHomePath] stringByAppendingPathComponent:name];
    NSString *newFilePath = [[self.class projectsHomePath] stringByAppendingPathComponent:newName];
    [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:newFilePath error:nil];
}

- (NSArray *)projectNameList
{
    NSArray *fileNameList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.class projectsHomePath] error:nil];
    NSMutableArray *tmpFileNameList = [NSMutableArray array];
    for(NSString *fileName in fileNameList){
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:[[self.class projectsHomePath] stringByAppendingPathComponent:fileName] isDirectory:&isDirectory];
        if(isDirectory){
            [tmpFileNameList addObject:fileName];
        }
    }
    return tmpFileNameList;
}

+ (NSString *)projectsHomePath
{
    NSString *path = [[CommonUtils documentPath] stringByAppendingPathComponent:@"projects"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return path;
}

@end
