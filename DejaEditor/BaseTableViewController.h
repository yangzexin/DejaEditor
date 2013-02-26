//
//  BaseTableViewController.h
//  imyvoa
//
//  Created by yangzexin on 13-2-4.
//
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@interface BaseTableViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, readonly)UITableView *tableView;
- (UITableView *)createTableView;
- (UITableViewStyle)tableViewStyle;

@end
