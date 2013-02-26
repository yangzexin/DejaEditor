//
//  BaseSearchViewController.m
//  CodeEditor
//
//  Created by yangzexin on 13-2-20.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "BaseSearchViewController.h"

@implementation BaseSearchViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_searchBar release];
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    _searchBar = [UISearchBar new];
    self.searchBar.frame = self.navigationController.navigationBar.frame;
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.delegate = self;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.tintColor = [UIColor clearColor];
    for(UIView *subview in [self.searchBar subviews]){
        if([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]){
            [subview removeFromSuperview];
        }
    }
    UITextField *textField = [self searchTextField];
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.returnKeyType = UIReturnKeyDone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShowNotification:)
                                                     name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHideNotification:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.searchBar];
    CGRect tmpRect = self.searchBar.frame;
    tmpRect.origin.y = -tmpRect.size.height;
    self.searchBar.frame = tmpRect;
    tmpRect.origin.y = 0;
    
    [UIView animateWithDuration:0.25f animations:^{
        self.searchBar.frame = tmpRect;
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    CGRect tmpRect = self.searchBar.frame;
    tmpRect.origin.y = -tmpRect.size.height;
    
    [UIView animateWithDuration:0.25f animations:^{
        self.searchBar.frame = tmpRect;
    } completion:^(BOOL finished) {
        [self.searchBar removeFromSuperview];
    }];
}

#pragma mark - private methods
- (void)setPlaceholder:(NSString *)placeholder
{
    [self searchTextField].placeholder = placeholder;
}

- (NSString *)placeholder
{
    return [self searchTextField].placeholder;
}

- (UITextField *)searchTextField
{
    for(UIView *subview in [self.searchBar subviews]){
        if([subview isKindOfClass:[UITextField class]]){
            UITextField *field = (id)subview;
            return field;
        }
    }
    return nil;
}

#pragma mark - events
- (void)keyboardWillShowNotification:(NSNotification *)n
{
    CGFloat keyboardHeight = [[n.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    [UIView animateWithDuration:0.25f animations:^{
        CGRect tmpRect = self.tableView.frame;
        tmpRect.size.height = self.view.frame.size.height - keyboardHeight;
        self.tableView.frame = tmpRect;
    }];
}

- (void)keyboardWillHideNotification:(NSNotification *)n
{
    [UIView animateWithDuration:0.25f animations:^{
        self.tableView.frame = self.view.bounds;
    }];
}

@end
