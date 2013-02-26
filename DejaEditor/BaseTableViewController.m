//
//  BaseTableViewController.m
//  imyvoa
//
//  Created by yangzexin on 13-2-4.
//
//

#import "BaseTableViewController.h"

@implementation BaseTableViewController

- (void)dealloc
{
    [_tableView release];
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    _tableView = [[self createTableView] retain];
    [self.view addSubview:_tableView];
}

- (UITableView *)createTableView
{
    UITableView *tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:self.tableViewStyle] autorelease];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    return tableView;
}

- (UITableViewStyle)tableViewStyle
{
    return UITableViewStylePlain;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

@end
