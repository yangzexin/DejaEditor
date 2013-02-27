//
//  APIDocumentViewController.m
//  CodeEditor
//
//  Created by yangzexin on 13-2-20.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "DEAPIDocumentViewController.h"
#import "DEScriptAPIDocument.h"
#import "DEScriptAPIDocumentFactory.h"
#import "DEAPIClassViewController.h"

@interface DEAPIDocumentViewController () <UISearchBarDelegate>

@property(nonatomic, retain)id<DEScriptAPIDocument> APIDocument;
@property(nonatomic, retain)NSArray *classNameList;
@property(nonatomic, retain)NSArray *filterClassNameList;
@property(nonatomic, retain)UIBarButtonItem *doneButton;

@end

@implementation DEAPIDocumentViewController

- (void)dealloc
{
    self.insertTextBlock = nil;
    self.APIDocument = nil;
    self.classNameList = nil;
    self.filterClassNameList = nil;
    self.doneButton = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.APIDocument = [DEScriptAPIDocumentFactory scriptAPIDocument];
    self.contentSizeForViewInPopover = CGSizeMake(320, 480);
    
    return self;
}

- (void)loadView
{
    [super loadView];
    self.title = @"";
    CGFloat doneButtonWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 0 : 60;
    CGRect tmpRect = self.navigationController.navigationBar.frame;
    self.searchBar.frame = CGRectMake(0, 0, tmpRect.size.width - doneButtonWidth, tmpRect.size.height);
    self.searchBar.placeholder = @"Class name";
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        self.doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                         target:self
                                                                         action:@selector(doneButtonTapped)] autorelease];
        self.navigationItem.rightBarButtonItem = self.doneButton;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.classNameList = [self.APIDocument classList];
    self.filterClassNameList = self.classNameList;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.searchBar.showsCancelButton = NO;
}

#pragma mark - events
- (void)doneButtonTapped
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
    }else{
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.insertTextBlock){
        self.insertTextBlock([self.filterClassNameList objectAtIndex:indexPath.row]);
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSString *className = [self.filterClassNameList objectAtIndex:indexPath.row];
    DEAPIClassViewController *classVC = [[[DEAPIClassViewController alloc] initWithClassName:className
                                                                              methodList:[self.APIDocument methodListWithClassName:className]] autorelease];
    classVC.insertTextBlock = self.insertTextBlock;
    [self.navigationController pushViewController:classVC animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filterClassNameList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"__id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    cell.textLabel.text = [self.filterClassNameList objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText.length == 0){
        self.filterClassNameList = self.classNameList;
    }else{
        NSMutableArray *tmpClassNameList = [NSMutableArray array];
        for(NSString *className in self.classNameList){
            if([[className lowercaseString] hasPrefix:searchText]){
                [tmpClassNameList addObject:className];
            }
        }
        self.filterClassNameList = tmpClassNameList;
    }
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self.navigationItem setRightBarButtonItem:nil animated:NO];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [UIView animateWithDuration:0.25f animations:^{
            CGRect tmpRect = self.searchBar.frame;
            tmpRect.size.width = self.navigationController.navigationBar.frame.size.width;
            self.searchBar.frame = tmpRect;
        }];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.navigationItem setRightBarButtonItem:self.doneButton animated:NO];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [UIView animateWithDuration:0.25f animations:^{
            CGRect tmpRect = self.searchBar.frame;
            tmpRect.size.width = self.navigationController.navigationBar.frame.size.width - 60;
            self.searchBar.frame = tmpRect;
        }];
    }
}

@end
