//
//  CommonProjectManager.h
//  CodeEditor
//
//  Created by yangzexin on 2/17/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DEProjectManager.h"

@interface DEFileProjectManager : NSObject <DEProjectManager>

+ (NSString *)projectsHomePath;

@end
