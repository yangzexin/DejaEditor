//
//  SelectProjectViewController.h
//  CodeEditor
//
//  Created by yangzexin on 2/24/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"

@protocol Project;
@protocol ProjectManager;

@interface LinkProjectViewController : BaseTableViewController

@property(nonatomic, copy)void(^selectProjectBlock)(NSString *projectName, NSInteger index);
@property(nonatomic, copy)void(^removeProjectBlock)(NSString *projectName, NSInteger index);
@property(nonatomic, retain)id<ProjectManager>projectManager;

- (id)initWithProjectNameList:(NSArray *)projectNameList linkedProjectNameList:(NSArray *)linkedProjectNameList;

@end
