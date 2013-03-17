//
//  ProjectViewController.m
//  CodeEditor
//
//  Created by yangzexin on 2/14/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "DEProjectViewController.h"
#import "DEEditorViewController.h"
#import "SVApp.h"
#import "SVAppManager.h"
#import "DEProjectBundle.h"
#import "SVAlertDialog.h"
#import "SVInputDialog.h"
#import "LogView.h"
#import "SVImagePicker.h"
#import "DELinkProjectViewController.h"
#import "SVLuaCommonUtils.h"
#import "LINavigationController.h"
#import "SVActionDialog.h"

@interface DEProjectViewController ()

@property(nonatomic, retain)NSArray *scriptNameList;
@property(nonatomic, retain)NSArray *resourceNameList;
@property(nonatomic, retain)NSMutableArray *runningAppList;
@property(nonatomic, retain)UIViewController *beforeRunLastViewController;
@property(nonatomic, retain)NSArray *editToolbarItems;
@property(nonatomic, retain)UIBarButtonItem *linkProjectButton;
@property(nonatomic, retain)UIBarButtonItem *setMainScriptButton;
@property(nonatomic, retain)NSArray *normalToolbarItems;
@property(nonatomic, retain)NSIndexPath *tableViewLastSelectedIndexPath;

@end

@implementation DEProjectViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.project = nil;
    self.projectManager = nil;
    self.scriptNameList = nil;
    self.resourceNameList = nil;
    self.runningAppList = nil;
    self.beforeRunLastViewController = nil;
    self.editToolbarItems = nil;
    self.linkProjectButton = nil;
    self.setMainScriptButton = nil;
    self.normalToolbarItems = nil;
    self.tableViewLastSelectedIndexPath = nil;
    [super dealloc];
}

- (id)initWithProject:(id<DEProject>)project
{
    self = [super init];
    
    self.runningAppList = [NSMutableArray array];
    self.project = project;
    self.title = [self.project name];
    
    if([self.project mainScriptName].length == 0){
        // no main script name speacified, try to find main script in project
        NSString *mainScriptName = nil;
        for(NSString *fileName in [self.project scriptNameList]){
            NSString *script = [self.project scriptContentWithName:fileName];
            if([SVLuaCommonUtils scriptIsMainScript:script]){
                mainScriptName = fileName;
                break;
            }
        }
        if(mainScriptName){
            // finded
            [self.project setMainScriptName:mainScriptName];
        }
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scriptNameList = [self.project scriptNameList];
    self.resourceNameList = [self.project resourceNameList];
    self.navigationController.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self stopAllRunningAppAnimated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)loadView
{
    [super loadView];
    self.navigationItem.rightBarButtonItem = [UIFactory borderedBarButtonItemWithTitle:NSLocalizedString(@"Edit", nil) target:self action:@selector(editButtonTapped:)];
    self.linkProjectButton = [UIFactory borderedBarButtonItemWithTitle:NSLocalizedString(@"Link Other Project", nil) target:self action:@selector(linkButtonTapped)];
    self.setMainScriptButton = [UIFactory borderedBarButtonItemWithTitle:NSLocalizedString(@"Set as Main", nil) target:self action:@selector(setAsMainButtonTapped)];
    self.editToolbarItems = @[self.linkProjectButton,
                              self.setMainScriptButton,
                              [UIFactory barButtonItemSystemItemFlexibleSpace],
                              [UIFactory barButtonItemSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped)],
                              ];
    self.normalToolbarItems = @[
                                [UIFactory borderedBarButtonItemWithTitle:@"Console" target:self action:@selector(consoleButtonTapped)],
                                [UIFactory barButtonItemSystemItemFlexibleSpace],
                                [UIFactory barButtonItemSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(runButtonTapped)]
                                ];
    
    self.toolbarItems = self.normalToolbarItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsSelectionDuringEditing = YES;
}

#pragma mark - private methods
- (NSString *)autoGenerateMainScript
{
    NSString *autoGenerateMainScriptName = @"main";
    NSString *script = @"function main(argu)\n\treturn nil;\nend\n";
    BOOL mainExists = [self.project scriptExistsWithName:autoGenerateMainScriptName];
    if(mainExists){
        script = [NSString stringWithFormat:@"%@\n%@", [self.project scriptContentWithName:autoGenerateMainScriptName], script];
    }
    [self.project saveScriptWithName:autoGenerateMainScriptName content:script];
    [self.project setMainScriptName:autoGenerateMainScriptName];
    self.scriptNameList = [self.project scriptNameList];
    [self.tableView reloadData];
    return autoGenerateMainScriptName;
}

- (void)runProjectWithMainScriptName:(NSString *)mainScriptName
{
    [[LogView sharedInstance] clear];
    self.beforeRunLastViewController = [[self.navigationController viewControllers] lastObject];
    DEProjectBundle *bundle = [[[DEProjectBundle alloc] initWithProject:self.project] autorelease];
    bundle.mainScriptName = mainScriptName;
    if([bundle mainScript].length == 0){
        [SVAlertDialog showWithTitle:@"没有找到程序入口函数main，是否创建?" message:nil completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
            if(buttonIndex == 1){
                NSMutableArray *viewControllers = [NSMutableArray array];
                for(UIViewController *viewController in self.navigationController.viewControllers){
                    [viewControllers addObject:viewController];
                    if(viewController == self){
                        break;
                    }
                }
                self.navigationController.viewControllers = viewControllers;
                [self editScriptWithName:[self autoGenerateMainScript]];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"创建", nil];
    }else{
        LINavigationController *nc = [[LINavigationController new] autorelease];
        [nc setStopButtonTapBlock:^{
            [self stopAllRunningAppAnimated:NO];
        }];
        [nc setConsoleButtonTapBlock:^{
            [[LogView sharedInstance] setHidden:NO];
        }];
        SVApp *app = [[[SVApp alloc] initWithScriptBundle:bundle relatedViewController:nc] autorelease];
        [app setConsoleOutputBlock:^(NSString *output) {
            VLog(@"%@", output);
        }];
        [self presentViewController:nc animated:YES completion:nil];
        [SVAppManager runApp:app];
        [self.runningAppList addObject:app];
    }
}

- (void)stopAllRunningAppAnimated:(BOOL)animated
{
    [[LogView sharedInstance] setHidden:YES];
    if(self.runningAppList.count == 0){
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    NSMutableArray *newViewControllers = [NSMutableArray array];
    for(UIViewController *viewController in [self.navigationController viewControllers]){
        [newViewControllers addObject:viewController];
        if(viewController == self.beforeRunLastViewController){
            break;
        }
    }
    [self.navigationController setViewControllers:newViewControllers animated:animated];
    
    for(SVApp *app in self.runningAppList){
        [SVAppManager destoryAppWithAppId:[app.scriptBundle bundleId]];
        [[LogView sharedInstance] log:[NSString stringWithFormat:@"stop app:%@", [app.scriptBundle bundleId]]];
    }
    [self.runningAppList removeAllObjects];
}

- (void)createScript
{
    [SVInputDialog showWithTitle:@"输入脚本名称" message:nil cancelButtonTitle:@"取消" approveButtonTitle:@"确定" completion:^(NSString *input) {
        if(input.length != 0){
            if([self.project scriptExistsWithName:input]){
                [SVAlertDialog showWithTitle:nil message:@"文件已存在" completion:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            }else{
                [self createScriptWithName:input];
            }
        }
    }];
}

- (void)createScriptWithName:(NSString *)scriptName
{
    [self.project saveScriptWithName:scriptName content:@""];
    self.scriptNameList = [self.project scriptNameList];
    [self.tableView reloadData];
}

- (void)createImage
{
    [SVImagePicker presentWithViewController:self completion:^(UIImage *image) {
        [self addImageToProject:image];
    }];
}

- (void)addImageToProject:(UIImage *)image
{
    [SVInputDialog showWithTitle:@"添加图片" message:@"请输入图片名" cancelButtonTitle:@"取消" approveButtonTitle:@"确定" completion:^(NSString *input) {
        if(input.length != 0){
            if(![[input lowercaseString] hasSuffix:@".png"]){
                input = [NSString stringWithFormat:@"%@.png", input];
            }
            NSData *imgData = UIImagePNGRepresentation(image);
            
            if([self.project resourceDataExistsWithName:input]){
                [SVAlertDialog showWithTitle:@"" message:[NSString stringWithFormat:@"文件%@已存在", input] completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
                    if(buttonIndex == 1){
                        [self saveImageWithName:input data:imgData];
                    }else if(buttonIndex == 2){
                        [self addImageToProject:image];
                    }
                } cancelButtonTitle:@"取消" otherButtonTitles:@"覆盖", @"重新输入", nil];
            }else{
                [self saveImageWithName:input data:imgData];
            }
        }
    }];
}

- (void)saveImageWithName:(NSString *)imgName data:(NSData *)data
{
    [self.project saveResourceData:data name:imgName];
    self.resourceNameList = [self.project resourceNameList];
    [self.tableView reloadData];
}

- (void)editScriptWithName:(NSString *)scriptName
{
    
    DEEditorViewController *editorVC = [[[DEEditorViewController alloc] initWithProject:self.project
                                                                         scriptName:scriptName] autorelease];
    [editorVC setRunProjectBlock:^(NSString *scriptName) {
        [self runProjectWithMainScriptName:scriptName];
    }];
    [editorVC setStopRunningBlock:^{
        [self stopAllRunningAppAnimated:YES];
    }];
    [self.navigationController pushViewController:editorVC animated:YES];
}

- (void)updateToolbarItemsStatesWithSelectState:(BOOL)selected
{
    self.setMainScriptButton.enabled = selected;
}

#pragma mark - events
- (void)consoleButtonTapped
{
    [[LogView sharedInstance] setHidden:NO];
}

- (void)runButtonTapped
{
    [self runProjectWithMainScriptName:nil];
}

- (void)stopButtonTapped
{
    [self stopAllRunningAppAnimated:YES];
//    [[LogView sharedInstance] setHidden:![[LogView sharedInstance] hidden]];
}

- (void)addButtonTapped
{
    [SVAlertDialog showWithTitle:@"新建文件" message:nil completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
        if(buttonIndex == 1){
            [self createScript];
        }else if(buttonIndex == 2){
            [self createImage];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"脚本", @"图片", nil];
}

- (void)editButtonTapped:(UIBarButtonItem *)editButton
{
    editButton.style = editButton.style == UIBarButtonItemStyleDone ? UIBarButtonItemStyleBordered : UIBarButtonItemStyleDone;
    BOOL editing = editButton.style == UIBarButtonItemStyleDone;
    editButton.title = editing ? NSLocalizedString(@"Done", nil) : NSLocalizedString(@"Edit", nil);
    [self.tableView setEditing:editing animated:YES];
    [self setToolbarItems:editing ? self.editToolbarItems : self.normalToolbarItems animated:YES];
    [self updateToolbarItemsStatesWithSelectState:NO];
}

- (void)linkButtonTapped
{
    NSMutableArray *projectNameList = [NSMutableArray arrayWithArray:[self.projectManager projectNameList]];
    [projectNameList removeObject:[self.project name]];
    DELinkProjectViewController *selectProjectVC = [[[DELinkProjectViewController alloc] initWithProjectNameList:projectNameList
                                                                                           linkedProjectNameList:[self.project linkedProjectNameList]] autorelease];
    selectProjectVC.projectManager = self.projectManager;
    [selectProjectVC setSelectProjectBlock:^(NSString *projectName, NSInteger index) {
        NSMutableArray *newLinkProjectNameList = [NSMutableArray arrayWithArray:[self.project linkedProjectNameList]];
        if([newLinkProjectNameList indexOfObject:projectName] == NSNotFound){
            [newLinkProjectNameList addObject:projectName];
            [self.project setLinkedProjectNameList:newLinkProjectNameList];
            [self.project sychronizeProjectConfiguration];
            return YES;
        }else{
            [SVAlertDialog showWithTitle:@"链接项目失败，该项目已经链接" message:nil completion:nil cancelButtonTitle:@"确定" otherButtonTitleList:nil];
        }
        return NO;
    }];
    [selectProjectVC setRemoveProjectBlock:^(NSString *projectName, NSInteger index) {
        NSMutableArray *newLinkProjectNameList = [NSMutableArray arrayWithArray:[self.project linkedProjectNameList]];
        [newLinkProjectNameList removeObjectAtIndex:index];
        [self.project setLinkedProjectNameList:newLinkProjectNameList];
        [self.project sychronizeProjectConfiguration];
        
    }];
    selectProjectVC.title = NSLocalizedString(@"Link Project", nil);
    UINavigationController *nc = [[[UINavigationController alloc] initWithRootViewController:selectProjectVC] autorelease];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        nc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentModalViewController:nc animated:YES];
}

- (void)setAsMainButtonTapped
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSString *scriptName = [self.scriptNameList objectAtIndex:indexPath.row];
    NSString *script = [self.project scriptContentWithName:scriptName];
    if([SVLuaCommonUtils scriptIsMainScript:script]){
        [self.project setMainScriptName:scriptName];
        [self.tableView reloadData];
    }else{
        [SVAlertDialog showWithTitle:NSLocalizedString(@"error", nil)
                           message:[NSString stringWithFormat:@"Cannot find main function in script:%@", scriptName]
                        completion:nil
                 cancelButtonTitle:@"确定"
                 otherButtonTitles:nil];
    }
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
    if(!tableView.isEditing){
        if(indexPath.section == 0){
            [self editScriptWithName:[self.scriptNameList objectAtIndex:indexPath.row]];
        }else if(indexPath.section == 1){
            NSString *resName = [self.resourceNameList objectAtIndex:indexPath.row];
            NSData *resData = [self.project resourceDataWithName:resName];
            NSArray *projectNameList = [self.projectManager projectNameList];
            [SVActionDialog showWithTitle:@"选择已有项目打开文件" completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
                if(buttonIndex < projectNameList.count){
                    [[LogView sharedInstance] clear];
                    id<DEProject> selectedProject = [self.projectManager projectWithName:[projectNameList objectAtIndex:buttonIndex]];
                    DEProjectBundle *bundle = [[[DEProjectBundle alloc] initWithProject:selectedProject] autorelease];
                    LINavigationController *nc = [[LINavigationController new] autorelease];
                    [nc setStopButtonTapBlock:^{
                        [self stopAllRunningAppAnimated:NO];
                    }];
                    SVApp *app = [[[SVApp alloc] initWithScriptBundle:bundle relatedViewController:nc] autorelease];
                    [app setConsoleOutputBlock:^(NSString *output) {
                        [[LogView sharedInstance] log:output];
                    }];
                    [self presentViewController:nc animated:YES completion:nil];
                    [self.runningAppList addObject:app];
                    [SVAppManager runApp:app params:resData];
                }
            } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitleList:projectNameList];
        }
    }else{
        if(indexPath.section == 0){
            [self updateToolbarItemsStatesWithSelectState:YES];
            if(self.tableViewLastSelectedIndexPath
               && indexPath.section == self.tableViewLastSelectedIndexPath.section
               && indexPath.row == self.tableViewLastSelectedIndexPath.row){
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                [self updateToolbarItemsStatesWithSelectState:NO];
            }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSString *fileName = indexPath.section == 0 ? [self.scriptNameList objectAtIndex:indexPath.row] : [self.resourceNameList objectAtIndex:indexPath.row];
        [SVAlertDialog showWithTitle:@"" message:[NSString stringWithFormat:@"删除%@?", fileName] completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
            if(buttonIndex == 1){
                if(indexPath.section == 0){
                    [self.project removeScriptWithName:fileName];
                    self.scriptNameList = [self.project scriptNameList];
                }else if(indexPath.section == 1){
                    [self.project removeResourceDataWithName:fileName];
                    self.resourceNameList = [self.project resourceNameList];
                }
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [tableView endUpdates];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return @"Scripts";
    }else if(section == 1){
        return @"Resources";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return [self.scriptNameList count];
    }else if(section == 1){
        return [self.resourceNameList count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.textColor = [UIColor blackColor];
    if(indexPath.section == 0){
        NSString *scriptName = [self.scriptNameList objectAtIndex:indexPath.row];
        cell.textLabel.text = scriptName;
        if([scriptName isEqualToString:[self.project mainScriptName]]){
            cell.textLabel.textColor = [UIColor blueColor];
        }
    }else if(indexPath.section == 1){
        cell.textLabel.text = [self.resourceNameList objectAtIndex:indexPath.row];
    }
    
    return cell;
}

@end
