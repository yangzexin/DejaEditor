//
//  EditorViewController.h
//  CodeEditor
//
//  Created by yangzexin on 2/12/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DEBaseViewController.h"
#import "DEProject.h"

@interface DEEditorViewController : DEBaseViewController

@property(nonatomic, copy)void(^runProjectBlock)(NSString *scriptName);
@property(nonatomic, copy)void(^stopRunningBlock)();
- (id)initWithProject:(id<DEProject>)project scriptName:(NSString *)scriptName;

@end
