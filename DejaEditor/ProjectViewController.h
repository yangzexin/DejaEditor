//
//  ProjectViewController.h
//  CodeEditor
//
//  Created by yangzexin on 2/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"
#import "Project.h"
#import "ProjectManager.h"

@interface ProjectViewController : BaseTableViewController

@property(nonatomic, retain)id<Project> project;
@property(nonatomic, retain)id<ProjectManager> projectManager;
- (id)initWithProject:(id<Project>)project;

@end
