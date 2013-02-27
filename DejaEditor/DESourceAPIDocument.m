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

@interface DESourceAPIDocument ()

@property(nonatomic, retain)NSArray *classNameList;
@property(nonatomic, retain)NSArray *classFilePathList;

@end

@implementation DESourceAPIDocument

- (void)dealloc
{
    self.classNameList = nil;
    self.classFilePathList = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"BaseScripts" ofType:@"bundle"]];
    NSString *bundlePath = [bundle bundlePath];
    NSMutableArray *tmpClassFilePathList = [NSMutableArray array];
    NSMutableArray *tmpClassNameList = [NSMutableArray array];
    [SVFileUtils enumerateWithDirectoryPath:bundlePath filePathBlock:^(NSString *filePath, BOOL isDirectory) {
        if(!isDirectory){
            [tmpClassFilePathList addObject:filePath];
            [tmpClassNameList addObject:[[filePath lastPathComponent] stringByDeletingPathExtension]];
        }
    }];
    self.classFilePathList = tmpClassFilePathList;
    self.classNameList = tmpClassNameList;
    
    return self;
}

- (NSArray *)classList
{
    return self.classNameList;
}

- (NSArray *)methodListWithClassName:(NSString *)className
{
    NSInteger index = [self.classNameList indexOfObject:className];
    if(index != NSNotFound){
        NSString *classFilePath = [self.classFilePathList objectAtIndex:index];
        return [self methodListWithClassFilePath:classFilePath className:className];
    }
    return nil;
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
        if([methodName hasPrefix:className] && ([methodName find:@"." fromIndex:0] != -1 || [methodName find:@":" fromIndex:0] != -1)){
            methodName = [methodName substringWithBeginIndex:className.length endIndex:methodName.length];
            [methodList addObject:methodName];
        }
    }
    return methodList;
}

@end
