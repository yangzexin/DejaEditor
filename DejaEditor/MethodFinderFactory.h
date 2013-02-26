//
//  MethodFinderFactory.h
//  CodeEditor
//
//  Created by yangzexin on 13-2-21.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MethodFinder;
@protocol Project;

@interface MethodFinderFactory : NSObject

+ (id<MethodFinder>)methodFinderWithProject:(id<Project>)project scriptName:(NSString *)scriptName;

@end
