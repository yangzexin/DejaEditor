//
//  ArrayMethodFinder.h
//  CodeEditor
//
//  Created by yangzexin on 13-2-21.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DEMethodFinder.h"

@protocol DEProject;

@interface DEArrayMethodFinder : NSObject <DEMethodFinder>

- (id)initWithProject:(id<DEProject>)project scriptName:(NSString *)scriptName;

@end
