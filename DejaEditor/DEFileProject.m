//
//  CommonProject.m
//  CodeEditor
//
//  Created by yangzexin on 2/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "DEFileProject.h"
#import "SVLuaCommonUtils.h"
#import "DEProjectManager.h"

@interface DEFileProject ()

@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *projectPath;
@property(nonatomic, retain)NSMutableDictionary *infoDict;

@end

@implementation DEFileProject

- (void)dealloc
{
    self.projectManager = nil;
    self.name = nil;
    self.infoDict = nil;
    self.projectPath = nil;
    [super dealloc];
}

- (id)initWithName:(NSString *)name projectPath:(NSString *)projectPath
{
    self = [super init];
    
    self.name = name;
    self.projectPath = projectPath;
    
    if(![self projectExists]){
        [self createProjectWithName:name];
    }else{
        self.infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:[self projectInfoFilePath]];
        if(!self.infoDict){
            self.infoDict = [NSMutableDictionary dictionaryWithDictionary:[self createNormalInfoDictionary]];
            [self saveInfoDict];
        }
    }
    
    return self;
}

- (void)saveInfoDict
{
    [self.infoDict writeToFile:[self projectInfoFilePath] atomically:NO];
}

- (BOOL)mainScriptExists
{
    for(NSString *scriptName in [self scriptNameList]){
        if([SVLuaCommonUtils scriptIsMainScript:[self scriptContentWithName:scriptName]]){
            return YES;
        }
    }
    return NO;
}

- (NSString *)filterScriptName:(NSString *)scriptName
{
    if(![[scriptName lowercaseString] hasSuffix:@".lua"]){
        scriptName = [NSString stringWithFormat:@"%@.lua", scriptName];
    }
    return scriptName;
}

- (void)saveScriptWithName:(NSString *)name content:(NSString *)content
{
    NSString *filePath = [[self projectPath] stringByAppendingPathComponent:[self filterScriptName:name]];
    [content writeToFile:filePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)scriptContentWithName:(NSString *)name
{
    NSString *filePath = [[self projectPath] stringByAppendingPathComponent:[self filterScriptName:name]];
    return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

- (void)removeScriptWithName:(NSString *)name
{
    NSString *filePath = [[self projectPath] stringByAppendingPathComponent:[self filterScriptName:name]];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

- (BOOL)scriptExistsWithName:(NSString *)name
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[[self projectPath] stringByAppendingPathComponent:[self filterScriptName:name]]];
}

- (void)saveResourceData:(NSData *)resData name:(NSString *)name
{
    if([self resourceDataExistsWithName:name]){
        [self removeResourceDataWithName:name];
    }
    NSString *filePath = [[self projectPath] stringByAppendingPathComponent:name];
    
    [resData writeToFile:filePath atomically:NO];
}

- (NSData *)resourceDataWithName:(NSString *)name
{
    NSString *filePath = [[self projectPath] stringByAppendingPathComponent:name];
    return [NSData dataWithContentsOfFile:filePath];
}

- (BOOL)resourceDataExistsWithName:(NSString *)name
{
    NSString *filePath = [[self projectPath] stringByAppendingPathComponent:name];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

- (void)removeResourceDataWithName:(NSString *)name
{
    NSString *filePath = [[self projectPath] stringByAppendingPathComponent:name];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

- (NSArray *)scriptNameList
{
    NSMutableArray *nameList = [NSMutableArray array];
    NSArray *fileNameList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self projectPath] error:nil];
    for(NSString *fileName in fileNameList){
        if([fileName hasSuffix:@".lua"]){
            NSString *fileNameExceptExtensions = [fileName substringToIndex:fileName.length - 4];
            [nameList addObject:fileNameExceptExtensions];
        }
    }
    return nameList;
}

- (NSArray *)resourceNameList
{
    NSMutableArray *nameList = [NSMutableArray array];
    NSArray *fileNameList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self projectPath] error:nil];
    for(NSString *fileName in fileNameList){
        if(![fileName hasSuffix:@".lua"]){
            [nameList addObject:fileName];
        }
    }
    return nameList;
}

- (NSString *)projectInfoFilePath
{
    return [[self projectPath] stringByAppendingPathComponent:@"project.plist"];
}

- (BOOL)projectExists
{
    return [[NSFileManager defaultManager] fileExistsAtPath:self.projectPath];
}

- (NSDictionary *)createNormalInfoDictionary
{
    return [NSDictionary dictionary];
}

- (void)createProjectWithName:(NSString *)name
{
    [[NSFileManager defaultManager] createDirectoryAtPath:[self projectPath] withIntermediateDirectories:NO attributes:nil error:nil];
    NSDictionary *projectInfoDict = [self createNormalInfoDictionary];
    [projectInfoDict writeToFile:[self projectInfoFilePath] atomically:NO];
    
    self.infoDict = [NSMutableDictionary dictionaryWithDictionary:projectInfoDict];
}

- (void)addFileWithName:(NSString *)fileName data:(NSData *)data
{
    NSString *lowerFileName = [fileName lowercaseString];
    if([lowerFileName hasSuffix:@".lua"]){
        [self saveScriptWithName:fileName content:[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
    }else{
        [self saveResourceData:data name:fileName];
    }
}

- (void)removeFileWithName:(NSString *)fileName
{
    NSString *lowerFileName = [fileName lowercaseString];
    if([lowerFileName hasSuffix:@".lua"]){
        [self removeScriptWithName:fileName];
    }else{
        [self removeResourceDataWithName:fileName];
    }
}

- (void)setProperty:(id)object forKey:(NSString *)key
{
    if(object && key){
        [self.infoDict setObject:object forKey:key];
    }
    [self saveInfoDict];
}

- (id)propertyForKey:(NSString *)key
{
    return [self.infoDict objectForKey:key];
}

- (void)sychronizeProjectConfiguration
{
    [self saveInfoDict];
}

- (void)setLinkedProjectNameList:(NSArray *)linkedProjectNameList
{
    if(linkedProjectNameList){
        [self.infoDict setObject:linkedProjectNameList forKey:kProjectLinkedProjectKey];
    }
}

- (NSArray *)linkedProjectNameList
{
    return [self.infoDict objectForKey:kProjectLinkedProjectKey];
}

- (NSArray *)linkedProjectList
{
    NSMutableArray *projectList = [NSMutableArray array];
    for(NSString *projectName in self.linkedProjectNameList){
        if([self.projectManager projectExistsWithName:projectName]){
            id<DEProject> tmpProject = [self.projectManager projectWithName:projectName];
            [projectList addObject:tmpProject];
        }else{
            NSLog(@"project:%@ linked project:%@ cannot be found", [self name], projectName);
        }
    }
    return projectList;
}

- (void)setMainScriptName:(NSString *)name
{
    if(name){
        [self.infoDict setObject:name forKey:kProjectMainScriptNameKey];
        [self sychronizeProjectConfiguration];
    }
}

- (NSString *)mainScriptName
{
    return [self.infoDict objectForKey:kProjectMainScriptNameKey];
}

@end
