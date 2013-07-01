//
//  ZipProjectManager.m
//  CodeEditor
//
//  Created by yangzexin on 13-2-19.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "DEZipProjectManager.h"
#import "YXZipHandler.h"
#import "YXZipHandlerFactory.h"
#import "DEProject.h"
#import "YXCommonUtils.h"
#import "YXLuaScriptCompiler.h"

NSString *kPackageFileExtenstion = @".pkg";

@implementation DEZipProjectManager

+ (NSArray *)zipProjectNameList
{
    NSString *documentPath = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    NSArray *fileNameList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath error:nil];
    NSMutableArray *zipFileList = [NSMutableArray array];
    for(NSString *fileName in fileNameList){
        BOOL isDir;
        NSString *lowercaseFileName = [fileName lowercaseString];
        if(([lowercaseFileName hasSuffix:@".zip"]
            || [lowercaseFileName hasSuffix:kPackageFileExtenstion])
           && [[NSFileManager defaultManager] fileExistsAtPath:[documentPath stringByAppendingPathComponent:fileName] isDirectory:&isDir]
           && !isDir){
            [zipFileList addObject:fileName];
        }
    }
    return zipFileList;
}

+ (void)unzipProjectWithName:(NSString *)zipProjectName toDirectoryPath:(NSString *)toDirectoryPath
{
    NSString *documentPath = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    NSString *zipFilePath = [documentPath stringByAppendingPathComponent:zipProjectName];
    id<YXZipHandler> zipHandler = [YXZipHandlerFactory defaultZipHandler];
    [zipHandler unzipWithFilePath:zipFilePath toDirectoryPath:toDirectoryPath];
}

+ (void)zipProject:(id<DEProject>)mainProject
{
    BOOL zipLinkedProject = NO;
    id<YXZipHandler> zipHandler = [YXZipHandlerFactory defaultZipHandler];
    NSString *tmpPath = [NSString stringWithFormat:@"%@/tmp", NSHomeDirectory()];
    tmpPath = [tmpPath stringByAppendingPathComponent:@"__tmp"];
    if([[NSFileManager defaultManager] fileExistsAtPath:tmpPath]){
        [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
    }
    NSString *projectPath = [tmpPath stringByAppendingPathComponent:[mainProject name]];
    [[NSFileManager defaultManager] createDirectoryAtPath:projectPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    NSMutableArray *projectList = [NSMutableArray array];
    if(zipLinkedProject){
        [projectList addObjectsFromArray:[mainProject linkedProjectList]];
    }
    [projectList addObject:mainProject];// add main project to last, as to override resource files
    for(id<DEProject> tmpProject in projectList){
        for(NSString *resName in [tmpProject resourceNameList]){
            NSData *data = [tmpProject resourceDataWithName:resName];
            NSString *filePath = [projectPath stringByAppendingPathComponent:resName];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [data writeToFile:filePath atomically:NO];
        }
        for(NSString *scriptName in [tmpProject scriptNameList]){
            NSData *data = [[tmpProject scriptContentWithName:scriptName] dataUsingEncoding:NSUTF8StringEncoding];
            NSString *filePath = [projectPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lua", scriptName]];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [data writeToFile:filePath atomically:NO];
        }
    }
    
    NSString *documentPath = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    NSString *zipFilePath = [documentPath stringByAppendingPathComponent:[YXCommonUtils countableTempFileName:[NSString stringWithFormat:@"%@.zip", [mainProject name]] atDirectory:documentPath]];
    [zipHandler zipWithDirectoryPath:projectPath toFilePath:zipFilePath];
}

+ (void)packageProject:(id<DEProject>)mainProject
{
    id<YXZipHandler> zipHandler = [YXZipHandlerFactory defaultZipHandler];
    NSString *tmpPath = [NSString stringWithFormat:@"%@/tmp", NSHomeDirectory()];
    tmpPath = [tmpPath stringByAppendingPathComponent:@"__tmp"];
    if([[NSFileManager defaultManager] fileExistsAtPath:tmpPath]){
        [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
    }
    NSString *projectPath = [tmpPath stringByAppendingPathComponent:[mainProject name]];
    [[NSFileManager defaultManager] createDirectoryAtPath:projectPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    NSString *resPath = [projectPath stringByAppendingPathComponent:@"res"];
    [[NSFileManager defaultManager] createDirectoryAtPath:resPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    NSString *scriptPath = [projectPath stringByAppendingPathComponent:@"src"];
    [[NSFileManager defaultManager] createDirectoryAtPath:scriptPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    NSMutableArray *projectList = [NSMutableArray arrayWithArray:[mainProject linkedProjectList]];
    [projectList addObject:mainProject];// add main project to last, as to override resource files
    
    id<YXScriptCompiler> scriptCompiler = [YXLuaScriptCompiler defaultScriptCompiler];
    for(id<DEProject> tmpProject in projectList){
        for(NSString *resName in [tmpProject resourceNameList]){
            NSData *data = [tmpProject resourceDataWithName:resName];
            NSString *filePath = [resPath stringByAppendingPathComponent:resName];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [data writeToFile:filePath atomically:NO];
            if([resName isEqualToString:@"project.plist"]){
                NSMutableDictionary *projectInfoDict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
                [projectInfoDict setObject:[NSNumber numberWithBool:YES] forKey:kProjectCompileStateKey];
                [projectInfoDict writeToFile:filePath atomically:NO];
            }
        }
        for(NSString *scriptName in [tmpProject scriptNameList]){
            NSData *data = [[scriptCompiler compileScript:[tmpProject scriptContentWithName:scriptName] scriptName:scriptName bundleId:[mainProject name]]
                            dataUsingEncoding:NSUTF8StringEncoding];
            NSString *filePath = [scriptPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lua", scriptName]];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [data writeToFile:filePath atomically:NO];
        }
    }
    
    NSString *documentPath = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    NSString *zipFilePath = [documentPath stringByAppendingPathComponent:
                             [YXCommonUtils countableTempFileName:[NSString stringWithFormat:@"%@%@", [mainProject name], kPackageFileExtenstion]
                                                    atDirectory:documentPath]];
    [zipHandler zipWithDirectoryPath:projectPath toFilePath:zipFilePath];
}

+ (NSString *)importZipWithContentOfFile:(NSString *)filePath
{
    NSString *documentPath = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    NSString *fileName = [filePath lastPathComponent];
    fileName = [YXCommonUtils countableTempFileName:fileName atDirectory:documentPath];
    [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:[documentPath stringByAppendingPathComponent:fileName] error:nil];
    return fileName;
}

+ (void)removeZipProjecWithName:(NSString *)zipProjectName
{
    NSString *documentPath = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    NSString *zipFilePath = [documentPath stringByAppendingPathComponent:zipProjectName];
    [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:nil];
}

+ (void)renameZipProjectWithName:(NSString *)zipProjectName newName:(NSString *)newName
{
    NSString *documentPath = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    NSString *zipFilePath = [documentPath stringByAppendingPathComponent:zipProjectName];
    NSString *newFilePath = [documentPath stringByAppendingPathComponent:newName];
    [[NSFileManager defaultManager] moveItemAtPath:zipFilePath toPath:newFilePath error:nil];
}

+ (BOOL)zipProjectExistsWithName:(NSString *)projectName
{
    if(![[projectName lowercaseString] hasSuffix:@".zip"]){
        projectName = [NSString stringWithFormat:@"%@.zip", projectName];
    }
    NSString *documentPath = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    return [[NSFileManager defaultManager] fileExistsAtPath:[documentPath stringByAppendingPathComponent:projectName]];
}

@end
