//
//  MethodFinder.h
//  CodeEditor
//
//  Created by yangzexin on 13-2-21.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DEScriptAnalyzer.h"

@protocol DEMethodFinder <DEScriptAnalyzer>

- (NSArray *)findInstanceMethodListWithPrefix:(NSString *)textPrefix;
- (NSArray *)findClassMethodListWithPrefix:(NSString *)textPrefix;
- (NSArray *)findCommonPretypeListWithPrefix:(NSString *)textPrefix;

- (void)findInstanceMethodListWithPrefix:(NSString *)textPrefix completion:(void(^)(NSArray *))completion;
- (void)findClassMethodListWithPrefix:(NSString *)textPrefix completion:(void(^)(NSArray *))completion;
- (void)findCommonPretypeListWithPrefix:(NSString *)textPrefix completion:(void(^)(NSArray *))completion;

- (NSArray *)instanceMethods;
- (NSArray *)classMethods;
- (NSArray *)commonPretypes;
- (NSArray *)localVarNameList;

@end
