//
//  APIClassViewController.m
//  CodeEditor
//
//  Created by yangzexin on 13-2-20.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "DEAPIClassViewController.h"
#import "DEScriptAPIDocument.h"

@interface DEAPIClassViewController ()

@property(nonatomic, retain)NSArray *methodList;
@property(nonatomic, retain)NSArray *filteredMethodList;
@property(nonatomic, copy)NSString *className;
@property(nonatomic, retain)UIButton *classNameLabel;

@end

@implementation DEAPIClassViewController

- (void)dealloc
{
    self.insertTextBlock = nil;
    self.methodList = nil;
    self.filteredMethodList = nil;
    self.className = nil;
    self.classNameLabel = nil;
    [super dealloc];
}

- (id)initWithClassName:(NSString *)className methodList:(NSArray *)methodList
{
    self = [super init];
    
    self.className = className;
    self.methodList = methodList;
    
    self.contentSizeForViewInPopover = CGSizeMake(320, 480);
    
    return self;
}

- (void)loadView
{
    [super loadView];
    CGRect tmpRect = self.searchBar.frame;
    tmpRect.origin.x = 60;
    tmpRect.size.width -= 60;
    self.searchBar.frame = tmpRect;
    
    self.classNameLabel = [UIFactory buttonWithType:UIButtonTypeRoundedRect];
    self.classNameLabel.frame = CGRectMake(5, 5, self.view.frame.size.width - 10, 50);
    [self.classNameLabel setTitle:self.className forState:UIControlStateNormal];
    self.classNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.classNameLabel addTarget:self action:@selector(classNameButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    [tableHeaderView addSubview:self.classNameLabel];
    self.tableView.tableHeaderView = tableHeaderView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.filteredMethodList = self.methodList;
}

#pragma mark - events
- (void)classNameButtonTapped
{
    if(self.insertTextBlock){
        self.insertTextBlock(self.className);
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length == 0){
        self.filteredMethodList = self.methodList;
    }else{
        searchText = [searchText lowercaseString];
        NSMutableArray *tmpMethodList = [NSMutableArray array];
        for(NSString *methodName in self.methodList){
            methodName = [methodName substringFromIndex:1];
            if([[methodName lowercaseString] hasPrefix:searchText]){
                [tmpMethodList addObject:methodName];
            }
        }
        self.filteredMethodList = tmpMethodList;
    }
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

#pragma mark - UITableViewDelegate & dataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [[UIPasteboard generalPasteboard] setString:[self.filteredMethodList objectAtIndex:indexPath.row]];
    if(self.insertTextBlock){
        self.insertTextBlock([self.filteredMethodList objectAtIndex:indexPath.row]);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredMethodList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"__id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    NSString *methodName = [self.filteredMethodList objectAtIndex:indexPath.row];
    BOOL classMethod = [methodName hasPrefix:@"."];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", methodName];
    cell.textLabel.textColor = classMethod ? [UIColor blueColor] : [UIColor blackColor];
    return cell;
}

@end
