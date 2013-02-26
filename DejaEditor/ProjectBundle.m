//
//  EditingBundle.m
//  CodeEditor
//
//  Created by yangzexin on 2/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "ProjectBundle.h"
#import "Project.h"
#import "LuaCommonUtils.h"

@interface ProjectBundle ()

@property(nonatomic, retain)id<Project> project;

@end

@implementation ProjectBundle

- (void)dealloc
{
    self.mainScriptName = nil;
    [super dealloc];
}

- (id)initWithProject:(id<Project>)project
{
    self = [super init];
    
    self.project = project;
    
    return self;
}

- (NSString *)bundleId
{
//    if(_mainScriptName.length != 0){
//        return [NSString stringWithFormat:@"%@_%@", [self.project name],  _mainScriptName];
//    }
    return [self.project name];
}

- (NSString *)scriptWithScriptName:(NSString *)scriptName
{
    NSString *script = [self.project scriptContentWithName:scriptName];
    if(script == nil && ![scriptName isEqualToString:@"main"]){
        NSArray *linkedProjectList = [self.project linkedProjectList];
        for(id<Project> relatedProject in linkedProjectList){
            script = [relatedProject scriptContentWithName:scriptName];
            if(script.length != 0){
                break;
            }
        }
    }
    return script;
}

- (NSData *)resourceWithName:(NSString *)resName
{
    NSData *data = [self.project resourceDataWithName:resName];
    if(data == nil){
        NSArray *linkedProjectList = [self.project linkedProjectList];
        for(id<Project> relatedProject in linkedProjectList){
            data = [relatedProject resourceDataWithName:resName];
            if(data != nil){
                break;
            }
        }
    }
    return [self.project resourceDataWithName:resName];
}

- (BOOL)resourceExistsWithName:(NSString *)resName
{
    BOOL exists = [self.project resourceDataExistsWithName:resName];
    
    return exists;
}

- (NSString *)mainScript
{
    if(_mainScriptName.length == 0){
        for(NSString *fileName in [self.project scriptNameList]){
            NSString *script = [self.project scriptContentWithName:fileName];
            if([LuaCommonUtils scriptIsMainScript:script]){
                return script;
            }
        }
    }else{
        return [self.project scriptContentWithName:_mainScriptName];
    }
    return nil;
}

- (NSString *)bundleVersion
{
    return @"1.0.0";
}

- (BOOL)isCompiled
{
    return NO;
}

@end
