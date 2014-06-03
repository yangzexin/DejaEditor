//
//  EditingBundle.h
//  CodeEditor
//
//  Created by yangzexin on 2/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVScriptBundle.h"
#import "DEProject.h"

@interface DEProjectBundle : NSObject <SVScriptBundle>

@property(nonatomic, copy)NSString *mainScriptName;

- (id)initWithProject:(id<DEProject>)project;

@end
