//
//  ProjectListViewController.m
//  CodeEditor
//
//  Created by yangzexin on 2/17/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "DEProjectListViewController.h"
#import "DEProjectManager.h"
#import "DEProjectManagerFactory.h"
#import "InputDialog.h"
#import "DEProjectViewController.h"
#import "AlertDialog.h"
#import "DEZipProjectManager.h"
#import "Waiting.h"
#import "SVLocalAppBundle.h"
#import "SVApp.h"
#import "SVAppManager.h"
#import "LINavigationController.h"

@interface DEProjectListViewController ()

@property(nonatomic, retain)id<DEProjectManager> projectManager;
@property(nonatomic, retain)NSArray *projectList;
@property(nonatomic, retain)NSArray *projectArchiveList;

@property(nonatomic, retain)UIBarButtonItem *archiveButton;
@property(nonatomic, retain)UIBarButtonItem *packageButton;
@property(nonatomic, retain)UIBarButtonItem *renameButton;
@property(nonatomic, retain)NSIndexPath *tableViewLastSelectedIndexPath;

@end

@implementation DEProjectListViewController

- (void)dealloc
{
    self.projectManager = nil;
    self.projectList = nil;
    self.projectArchiveList = nil;
    self.archiveButton = nil;
    self.packageButton = nil;
    self.renameButton = nil;
    self.tableViewLastSelectedIndexPath = nil;
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    self.title = NSLocalizedString(@"Projects", nil);
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addNewProjectButtonTapped)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil)
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:self
                                                                              action:@selector(editButtonTapped:)] autorelease];
    self.archiveButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Archive", nil)
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(archiveButtonTapped)] autorelease];
    self.packageButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Package", nil)
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(packageButtonTapped)] autorelease];
    self.renameButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Rename", nil)
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(renameButtonTapped)] autorelease];
    self.toolbarItems = @[self.archiveButton,
                          self.renameButton,
                          [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                          self.packageButton,
                          [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.projectManager = [DEProjectManagerFactory defaultProjectManager];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"projectImported"] == nil){
        [Waiting showWaiting:YES inView:self.view];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *demoProjectNameList = @[@"ImageViewer.zip", @"Queries.zip", @"TextViewer.zip", @"WebBrowser.zip", @"commlib.zip"];
            for(NSString *demoProjectName in demoProjectNameList){
                NSString *tmpPath = [[NSBundle mainBundle] pathForResource:demoProjectName ofType:nil];
                if(![DEZipProjectManager zipProjectExistsWithName:demoProjectName]){
                    [DEZipProjectManager importZipWithContentOfFile:tmpPath];
                    if(![self.projectManager projectExistsWithName:demoProjectName]){
                        NSString *tmpProjectPath = [self unzipProjectWithName:demoProjectName];
                        if(tmpProjectPath){
                            [self copyZipProjectToProjectLibraryFromDirectoryPath:tmpProjectPath];
                        }
                    }
                }
            }
            NSArray *pkgNameList = @[@"WebBrowser.pkg", @"Queries.pkg"];
            for(NSString *pkgName in pkgNameList){
                NSString *tmpPath = [[NSBundle mainBundle] pathForResource:pkgName ofType:nil];
                if([[NSFileManager defaultManager] fileExistsAtPath:tmpPath]){
                    [DEZipProjectManager importZipWithContentOfFile:tmpPath];
                }
            }
            [[NSUserDefaults standardUserDefaults] setObject:@"imported" forKey:@"projectImported"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadProjectList];
                [Waiting showWaiting:NO inView:self.view];
                [AlertDialog showWithTitle:@""
                                   message:@"zip包为源代码包，pkg包为可以直接点击运行的程序"
                                completion:nil
                         cancelButtonTitle:@"我知道了"
                      otherButtonTitleList:nil];
            });
        });
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadProjectList];
    self.navigationController.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
    
    [SVAppManager destoryAllApps];
}

#pragma mark - private methods
- (void)reloadProjectList
{
    self.projectList = [self.projectManager projectNameList];
    self.projectArchiveList = [DEZipProjectManager zipProjectNameList];
    [self.tableView reloadData];
    [self updateToolbarItemsStatesWithSelectState:NO];
}

- (BOOL)validateProjectName:(NSString *)projectName
{
    return YES;
}

- (NSString *)unzipProjectWithName:(NSString *)zipProjectName
{
    NSString *tmpPath = [NSString stringWithFormat:@"%@/tmp", NSHomeDirectory()];
    NSString *tmpFatherPath = [tmpPath stringByAppendingPathComponent:@"__tmp"];
    if([[NSFileManager defaultManager] fileExistsAtPath:tmpFatherPath]){
        [[NSFileManager defaultManager] removeItemAtPath:tmpFatherPath error:nil];
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:tmpFatherPath withIntermediateDirectories:NO attributes:nil error:nil];
    [DEZipProjectManager unzipProjectWithName:zipProjectName toDirectoryPath:tmpFatherPath];
    NSArray *fileNameList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tmpFatherPath error:nil];
    
    if(fileNameList.count == 1){
        NSString *folderName = [fileNameList lastObject];
        NSString *folderPath = [tmpFatherPath stringByAppendingPathComponent:folderName];
        BOOL isDir;
        if([[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDir] && isDir){
            return folderPath;
        }
    }
    return nil;
}

- (BOOL)copyZipProjectToProjectLibraryFromDirectoryPath:(NSString *)directoryPath
{
    NSString *projectName = [directoryPath lastPathComponent];
    if(![self.projectManager projectExistsWithName:projectName]){
        id<DEProject> project = [self.projectManager projectWithName:projectName];
        NSArray *fileNameList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
        for(NSString *fileName in fileNameList){
            NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
            [project addFileWithName:fileName data:[NSData dataWithContentsOfFile:filePath]];
        }
        [self reloadProjectList];
        return YES;
    }
    return NO;
}

- (void)updateToolbarItemsStatesWithSelectState:(BOOL)selected
{
    self.archiveButton.enabled = selected;
    self.renameButton.enabled = selected;
    self.packageButton.enabled = selected;
}

- (void)runPackagedProjectWithName:(NSString *)packagedProjectName
{
    
}

#pragma mark - events
- (void)addNewProjectButtonTapped
{
    [InputDialog showWithTitle:@"请输入项目的名称" message:nil cancelButtonTitle:@"取消" approveButtonTitle:@"确定" completion:^(NSString *input) {
        if(input.length != 0 && [self validateProjectName:input]){
            if([self.projectManager projectExistsWithName:input]){
                [AlertDialog showWithTitle:@"" message:@"项目已存在" completion:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                return;
            }
            [self.projectManager projectWithName:input];
            [self reloadProjectList];
        }
    }];
}

- (void)editButtonTapped:(UIBarButtonItem *)editButton
{
    editButton.style = editButton.style == UIBarButtonItemStyleDone ? UIBarButtonItemStyleBordered : UIBarButtonItemStyleDone;
    BOOL editing = editButton.style == UIBarButtonItemStyleDone;
    editButton.title = editing ? NSLocalizedString(@"Done", nil) : NSLocalizedString(@"Edit", nil);
    [self.tableView setEditing:editing animated:YES];
    [self.navigationController setToolbarHidden:!editing animated:YES];
    [self updateToolbarItemsStatesWithSelectState:NO];
}

- (void)archiveButtonTapped
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [DEZipProjectManager zipProject:[self.projectManager projectWithName:[self.projectList objectAtIndex:indexPath.row]]];
    [self reloadProjectList];
}

- (void)packageButtonTapped
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [DEZipProjectManager packageProject:[self.projectManager projectWithName:[self.projectList objectAtIndex:indexPath.row]]];
    [self reloadProjectList];
}

- (void)renameButtonTapped
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if(indexPath.section == 0){
        NSString *projectName = [self.projectList objectAtIndex:indexPath.row];
        [InputDialog showWithTitle:@"请输入新名称" message:nil initText:projectName cancelButtonTitle:@"取消" approveButtonTitle:@"确定" completion:^(NSString *input) {
            if(input.length != 0 && [self validateProjectName:input]){
                [self.projectManager renameProjectWithName:projectName newName:input];
                [self reloadProjectList];
            }
        }];
    }
}

- (void)returnButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self viewWillAppear:YES];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.tableView.editing){
        [self updateToolbarItemsStatesWithSelectState:NO];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.tableView.editing){
        if(indexPath.section == 1){
            return nil;
        }else{
            self.tableViewLastSelectedIndexPath = [tableView indexPathForSelectedRow];
        }
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.editing){
        if(indexPath.section == 0){
            [self updateToolbarItemsStatesWithSelectState:YES];
            if(self.tableViewLastSelectedIndexPath
               && indexPath.section == self.tableViewLastSelectedIndexPath.section
               && indexPath.row == self.tableViewLastSelectedIndexPath.row){
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                [self updateToolbarItemsStatesWithSelectState:NO];
            }
        }
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0){
        id<DEProject> project = [self.projectManager projectWithName:[self.projectList objectAtIndex:indexPath.row]];
        DEProjectViewController *projectVC = [[[DEProjectViewController alloc] initWithProject:project] autorelease];
        projectVC.projectManager = self.projectManager;
        [self.navigationController pushViewController:projectVC animated:YES];
    }else if(indexPath.section == 1){
        NSString *zipProjectName = [self.projectArchiveList objectAtIndex:indexPath.row];
        NSString *lowerZipProjectName = [zipProjectName lowercaseString];
        if([lowerZipProjectName hasSuffix:@".zip"]){
            [AlertDialog showWithTitle:@"" message:[NSString stringWithFormat:@"是否要解压项目%@", zipProjectName]
                            completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
                if(buttonIndex == 1){
                    NSString *unzipedProjectPath = [self unzipProjectWithName:zipProjectName];
                    if(unzipedProjectPath){
                        BOOL success = [self copyZipProjectToProjectLibraryFromDirectoryPath:unzipedProjectPath];
                        if(success){
                            [self reloadProjectList];
                        }else{
                            [AlertDialog showWithTitle:nil
                                               message:[NSString stringWithFormat:@"项目%@已经存在", zipProjectName]
                                            completion:nil
                                     cancelButtonTitle:@"确定"
                                  otherButtonTitleList:nil];
                        }
                    }else{
                        [AlertDialog showWithTitle:nil message:@"解压失败，不是有效的项目文件" completion:nil cancelButtonTitle:@"确定" otherButtonTitleList:nil];
                    }
                }
            } cancelButtonTitle:@"取消" otherButtonTitles:@"解压", nil];
        }else if([lowerZipProjectName hasSuffix:kPackageFileExtenstion]){
            [Waiting showWaiting:YES inView:self.view];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *unzipedProjectPath = [self unzipProjectWithName:zipProjectName];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Waiting showWaiting:NO inView:self.view];
                    if(unzipedProjectPath){
                        id<SVScriptBundle> sb = [[[SVLocalAppBundle alloc] initWithDirectory:unzipedProjectPath] autorelease];
                        LINavigationController *nc = [[LINavigationController new] autorelease];
                        [nc setStopButtonTapBlock:^{
                            [self dismissViewControllerAnimated:YES completion:nil];
                            [SVAppManager destoryAllApps];
                        }];
                        [self presentViewController:nc animated:YES completion:nil];
                        SVApp *app = [[[SVApp alloc] initWithScriptBundle:sb relatedViewController:nc] autorelease];
                        [SVAppManager runApp:app];
                    }else{
                        [AlertDialog showWithTitle:nil message:@"运行失败，不是有效的文件" completion:nil cancelButtonTitle:@"确定" otherButtonTitleList:nil];
                    }
                });
            });
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.editing ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return NO;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        if(indexPath.section == 0){
            NSString *projectName = [self.projectList objectAtIndex:indexPath.row];
            [AlertDialog showWithTitle:[NSString stringWithFormat:@"确定要删除项目%@吗", projectName] message:nil completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
                if(buttonIndex == 1){
                    [self.projectManager removeProjectWithName:projectName];
                    self.projectList = [self.projectManager projectNameList];
                    [tableView beginUpdates];
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [tableView endUpdates];
                }
            } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        }else if(indexPath.section == 1){
            NSString *zipProjectName = [self.projectArchiveList objectAtIndex:indexPath.row];
            [AlertDialog showWithTitle:[NSString stringWithFormat:@"确定要删除项目%@吗", zipProjectName]  message:nil completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
                if(buttonIndex == 1){
                    [DEZipProjectManager removeZipProjecWithName:zipProjectName];
                    self.projectArchiveList = [DEZipProjectManager zipProjectNameList];
                    [tableView beginUpdates];
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [tableView endUpdates];
                }
            } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return @"Projects";
    }else if(section == 1){
        return @"Project archives";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return self.projectList.count;
    }else if(section == 1){
        return self.projectArchiveList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"__id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.textColor = [UIColor blackColor];
    if(indexPath.section == 0){
        cell.textLabel.text = [self.projectList objectAtIndex:indexPath.row];
    }else if(indexPath.section == 1){
        cell.textLabel.text = [self.projectArchiveList objectAtIndex:indexPath.row];
        if([[cell.textLabel.text lowercaseString] hasSuffix:kPackageFileExtenstion]){
            cell.textLabel.textColor = [UIColor blueColor];
        }
    }
    return cell;
}

@end
