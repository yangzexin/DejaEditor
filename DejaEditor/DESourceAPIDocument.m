//
//  SourceAPIDocument.m
//  CodeEditor
//
//  Created by yangzexin on 2/19/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "DESourceAPIDocument.h"
#import "SVFileUtils.h"
#import "NSString+JavaLikeStringHandle.h"
#import "SVClassDefineChecker.h"

@interface DESourceAPIDocument ()

@property(nonatomic, retain)NSArray *classNameList;
@property(nonatomic, retain)NSDictionary *classFilePathDictionary;

@end

@implementation DESourceAPIDocument

- (void)dealloc
{
    self.classNameList = nil;
    self.classFilePathDictionary = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"BaseScripts" ofType:@"bundle"]];
    NSString *bundlePath = [bundle bundlePath];
    NSMutableArray *tmpClassNameList = [NSMutableArray array];
    NSMutableDictionary *tmpClassFilePathDictionary = [NSMutableDictionary dictionary];
    [SVFileUtils enumerateWithDirectoryPath:bundlePath filePathBlock:^(NSString *filePath, BOOL isDirectory) {
        if(!isDirectory){
            NSString *script = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            NSArray *scriptClassNameList = [self classNameListForScript:script];
            for(NSString *className in scriptClassNameList){
                [tmpClassNameList addObject:className];
                [tmpClassFilePathDictionary setObject:filePath forKey:className];
            }
        }
    }];
    [tmpClassNameList sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    self.classNameList = tmpClassNameList;
    self.classFilePathDictionary = tmpClassFilePathDictionary;
    
    return self;
}

- (NSArray *)classNameListForScript:(NSString *)script
{
    NSMutableArray *tmpClassNameList = [NSMutableArray array];
    [SVClassDefineChecker handleScript:script classNameBlock:^(NSString *className) {
        [tmpClassNameList addObject:className];
    }];
    return tmpClassNameList;
}

- (NSArray *)classList
{
    return self.classNameList;
}

- (NSArray *)methodListWithClassName:(NSString *)className
{
    NSString *classFilePath = [self.classFilePathDictionary objectForKey:className];
    return [self methodListWithClassFilePath:classFilePath className:className];
}

- (NSArray *)methodListWithClassFilePath:(NSString *)classFilePath className:(NSString *)className
{
    NSString *script = [NSString stringWithContentsOfFile:classFilePath encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *methodList = [NSMutableArray array];
    NSInteger beginIndex = -1;
    NSInteger endIndex = 0;
    NSString *matching = @"function ";
    while((beginIndex = [script find:matching fromIndex:endIndex]) != -1){
        beginIndex += matching.length;
        endIndex = [script find:@")" fromIndex:beginIndex];
        if(endIndex == -1){
            continue;
        }
        NSString *methodName = [script substringWithBeginIndex:beginIndex endIndex:endIndex + 1];
        methodName = [methodName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSInteger separatorIndex = [methodName find:@":" fromIndex:0];
        if(separatorIndex == -1){
            separatorIndex = [methodName find:@"." fromIndex:0];
        }
        if([methodName hasPrefix:className] && separatorIndex != -1){
            methodName = [methodName substringWithBeginIndex:separatorIndex endIndex:methodName.length];
            [methodList addObject:methodName];
        }
    }
    [methodList sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    return methodList;
}

@end
