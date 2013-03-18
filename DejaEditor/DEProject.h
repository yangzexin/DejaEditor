//
//  Project.h
//  CodeEditor
//
//  Created by yangzexin on 2/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXPORT NSString *kProjectLinkedProjectKey;
OBJC_EXPORT NSString *kProjectCompileStateKey;
OBJC_EXPORT NSString *kProjectMainScriptNameKey;
OBJC_EXPORT NSString *kProjectInfoListFileName;

@protocol DEProject <NSObject>

- (NSString *)name;
- (void)saveScriptWithName:(NSString *)name content:(NSString *)content;
- (NSString *)scriptContentWithName:(NSString *)name;
- (void)removeScriptWithName:(NSString *)name;
- (BOOL)scriptExistsWithName:(NSString *)name;

- (void)saveResourceData:(NSData *)resData name:(NSString *)name;
- (NSData *)resourceDataWithName:(NSString *)name;
- (void)removeResourceDataWithName:(NSString *)name;
- (BOOL)resourceDataExistsWithName:(NSString *)name;

- (void)addFileWithName:(NSString *)fileName data:(NSData *)data;
- (void)removeFileWithName:(NSString *)fileName;

- (NSArray *)scriptNameList;
- (NSArray *)resourceNameList;

- (void)setProperty:(id)object forKey:(NSString *)key;
- (id)propertyForKey:(NSString *)key;
- (void)sychronizeProjectConfiguration;

- (void)setLinkedProjectNameList:(NSArray *)linkedProjectNameList;
- (NSArray *)linkedProjectNameList;
- (NSArray *)linkedProjectList;

- (void)setMainScriptName:(NSString *)name;
- (NSString *)mainScriptName;

@end
