//
//  EditorViewController.h
//  CodeEditor
//
//  Created by yangzexin on 2/12/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import "Project.h"

@interface EditorViewController : BaseViewController

@property(nonatomic, copy)void(^runProjectBlock)(NSString *scriptName);
@property(nonatomic, copy)void(^stopRunningBlock)();
- (id)initWithProject:(id<Project>)project scriptName:(NSString *)scriptName;

@end
