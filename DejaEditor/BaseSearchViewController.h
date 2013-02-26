//
//  BaseSearchViewController.h
//  CodeEditor
//
//  Created by yangzexin on 13-2-20.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTableViewController.h"

@interface BaseSearchViewController : BaseTableViewController <UISearchBarDelegate>

@property(nonatomic, readonly)UISearchBar *searchBar;
@property(nonatomic, copy)NSString *placeholder;
@property(nonatomic, readonly)UITextField *searchTextField;

@end
