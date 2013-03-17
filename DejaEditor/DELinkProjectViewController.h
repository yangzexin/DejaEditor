//
//  SelectProjectViewController.h
//  CodeEditor
//
//  Created by yangzexin on 2/24/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DEBaseTableViewController.h"

@protocol DEProject;
@protocol DEProjectManager;

@interface DELinkProjectViewController : DEBaseTableViewController

@property(nonatomic, copy)BOOL(^selectProjectBlock)(NSString *projectName, NSInteger index);
@property(nonatomic, copy)void(^removeProjectBlock)(NSString *projectName, NSInteger index);
@property(nonatomic, retain)id<DEProjectManager>projectManager;

- (id)initWithProjectNameList:(NSArray *)projectNameList linkedProjectNameList:(NSArray *)linkedProjectNameList;

@end
