//
//  MethodFinderFactory.h
//  CodeEditor
//
//  Created by yangzexin on 13-2-21.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DEMethodFinder;
@protocol DEProject;

@interface DEMethodFinderFactory : NSObject

+ (id<DEMethodFinder>)methodFinderWithProject:(id<DEProject>)project scriptName:(NSString *)scriptName;

@end
