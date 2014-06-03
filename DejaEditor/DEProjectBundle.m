//
//  EditingBundle.m
//  CodeEditor
//
//  Created by yangzexin on 2/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "DEProjectBundle.h"
#import "DEProject.h"
#import "SVLuaCommonUtils.h"

@interface DEProjectBundle ()

@property(nonatomic, retain)id<DEProject> project;

@end

@implementation DEProjectBundle

- (void)dealloc
{
    self.mainScriptName = nil;
    [super dealloc];
}

- (id)initWithProject:(id<DEProject>)project
{
    self = [super init];
    
    self.project = project;
    
    return self;
}

- (NSString *)bundleId
{
    return [self.project name];
}

- (NSString *)scriptWithScriptName:(NSString *)scriptName
{
    NSString *script = [self.project scriptContentWithName:scriptName];
    if(script == nil && ![scriptName isEqualToString:@"main"]){
        NSArray *linkedProjectList = [self.project linkedProjectList];
        for(id<DEProject> relatedProject in linkedProjectList){
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
        for(id<DEProject> relatedProject in linkedProjectList){
            data = [relatedProject resourceDataWithName:resName];
            if(data != nil){
                return data;
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
            if([SVLuaCommonUtils scriptIsMainScript:script]){
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

- (NSArray *)scriptNames
{
    return nil;
}

- (NSArray *)resourceNames
{
    return nil;
}

@end
