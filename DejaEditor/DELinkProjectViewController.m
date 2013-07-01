//
//  SelectProjectViewController.m
//  CodeEditor
//
//  Created by yangzexin on 2/24/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "DELinkProjectViewController.h"
#import "DEProjectManager.h"
#import "YXAlertDialog.h"
#import "YXDelayControl.h"

@interface DELinkProjectViewController ()

@property(nonatomic, retain)NSArray *projectNameList;
@property(nonatomic, retain)NSMutableArray *unlinkedProjectNameList;
@property(nonatomic, retain)NSMutableArray *linkedProjectNameList;

@end

@implementation DELinkProjectViewController

- (void)dealloc
{
    self.selectProjectBlock = nil;
    self.removeProjectBlock = nil;
    self.projectManager = nil;
    self.projectNameList = nil;
    self.unlinkedProjectNameList = nil;
    self.linkedProjectNameList = nil;
    [super dealloc];
}

- (id)initWithProjectNameList:(NSArray *)projectNameList linkedProjectNameList:(NSArray *)linkedProjectNameList
{
    self = [super init];
    
    self.title = @"Link Other Projects";
    self.projectNameList = projectNameList;
    
    NSMutableArray *tmpUnlinkdProjectNameList = [NSMutableArray array];
    if(linkedProjectNameList.count != 0){
        for(NSString *projectName in projectNameList){
            if([linkedProjectNameList indexOfObject:projectName] == NSNotFound){
                [tmpUnlinkdProjectNameList addObject:projectName];
            }
        }
    }else{
        [tmpUnlinkdProjectNameList addObjectsFromArray:projectNameList];
    }
    self.unlinkedProjectNameList = tmpUnlinkdProjectNameList;
    self.linkedProjectNameList = [NSMutableArray arrayWithArray:linkedProjectNameList];
    
    
    return self;
}

- (void)loadView
{
    [super loadView];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(cancelButtontapped)] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - events
- (void)cancelButtontapped
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)doneButtonTapped
{
    if(self.selectProjectBlock){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *projectName = [self.unlinkedProjectNameList objectAtIndex:indexPath.row];
        self.selectProjectBlock(projectName, indexPath.row);
        [self.linkedProjectNameList addObject:projectName];
        [self.unlinkedProjectNameList removeObjectAtIndex:indexPath.row];
        self.navigationItem.rightBarButtonItem = nil;
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:1]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.linkedProjectNameList.count - 1 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        [[[[YXDelayControl alloc] initWithInterval:0.25f completion:^{
            [self.tableView reloadData];
        }] autorelease] start];
    }
//    [self dismissModalViewControllerAnimated:YES];
}

- (void)removeButtonTapped:(UIButton *)removeButton
{
    NSInteger index = removeButton.tag;
    [YXAlertDialog showWithTitle:@"确定要解除该项目吗?" message:nil completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
        if(buttonIndex == 1){
            if(self.removeProjectBlock){
                self.removeProjectBlock([self.linkedProjectNameList objectAtIndex:index], index);
            }
            [self.unlinkedProjectNameList addObject:[self.linkedProjectNameList objectAtIndex:index]];
            [self.linkedProjectNameList removeObjectAtIndex:index];
            self.navigationItem.rightBarButtonItem = nil;
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.unlinkedProjectNameList.count - 1 inSection:1]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            [[[[YXDelayControl alloc] initWithInterval:0.25f completion:^{
                [self.tableView reloadData];
            }] autorelease] start];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
}

#pragma mark - UITableViewDelegate & dataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"链接"
                                                                                   style:UIBarButtonItemStyleDone
                                                                                  target:self
                                                                                  action:@selector(doneButtonTapped)] autorelease];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return @"Linked Projects";
    }else if(section == 1){
        return @"Linkable Projects";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return self.linkedProjectNameList.count;
    }else if(section == 1){
        return self.unlinkedProjectNameList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"__id";
    static NSString *idnetifierForLinkedProject = @"_id_";
    
    if(indexPath.section == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idnetifierForLinkedProject];
        UILabel *nameLabel = nil;
        UIButton *removeButton = nil;
        if(!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idnetifierForLinkedProject] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            nameLabel = [[UILabel new] autorelease];
            nameLabel.font = [UIFont systemFontOfSize:14.0f];
            nameLabel.frame = CGRectMake(10, 0, tableView.frame.size.width - 20, tableView.rowHeight);
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.tag = 1001;
            [cell.contentView addSubview:nameLabel];
            
            removeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            removeButton.frame = CGRectMake(tableView.frame.size.width - 90, 5, 80, tableView.rowHeight - 10);
            [removeButton setTitle:@"Unlink" forState:UIControlStateNormal];
            [removeButton addTarget:self action:@selector(removeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:removeButton];
        }else{
            nameLabel = (id)[cell.contentView viewWithTag:1001];
            for(UIView *subview in [cell.contentView subviews]){
                if([subview isKindOfClass:[UIButton class]]){
                    removeButton = (id)subview;
                    break;
                }
            }
        }
        removeButton.tag = indexPath.row;
        nameLabel.textColor = [UIColor blueColor];
        NSString *projectName = [self.linkedProjectNameList objectAtIndex:indexPath.row];
        nameLabel.text = projectName;
        if(self.projectManager && ![self.projectManager projectExistsWithName:projectName]){
            nameLabel.textColor = [UIColor redColor];
        }
        
        return cell;
    }else if(indexPath.section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        }
        
        cell.textLabel.text = [self.unlinkedProjectNameList objectAtIndex:indexPath.row];
        return cell;
    }
    return nil;
}

@end
