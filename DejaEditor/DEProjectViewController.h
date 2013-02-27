//
//  ProjectViewController.h
//  CodeEditor
//
//  Created by yangzexin on 2/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DEBaseTableViewController.h"
#import "DEProject.h"
#import "DEProjectManager.h"

@interface DEProjectViewController : DEBaseTableViewController

@property(nonatomic, retain)id<DEProject> project;
@property(nonatomic, retain)id<DEProjectManager> projectManager;
- (id)initWithProject:(id<DEProject>)project;

@end
