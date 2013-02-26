//
//  ArrayMethodFinder.h
//  CodeEditor
//
//  Created by yangzexin on 13-2-21.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MethodFinder.h"

@protocol Project;

@interface ArrayMethodFinder : NSObject <MethodFinder>

- (id)initWithProject:(id<Project>)project scriptName:(NSString *)scriptName;

@end
