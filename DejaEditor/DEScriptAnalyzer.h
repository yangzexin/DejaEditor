//
//  ScriptVarNameAnalyzer.h
//  CodeEditor
//
//  Created by yangzexin on 2/21/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DEProject;

@protocol DEScriptAnalyzer <NSObject>

- (void)analyzeWithScriptName:(NSString *)scriptName script:(NSString *)script project:(id<DEProject>)project;
- (NSArray *)cachedFunctionPositionList;

@end
