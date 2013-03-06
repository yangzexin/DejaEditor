//
//  UIFactory.m
//  DejaEditor
//
//  Created by yangzexin on 13-2-27.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "UIFactory.h"
#import "UIWebViewAdditions.h"

@implementation UIFactory

+ (UITableView *)tableView
{
    return [self.class tableViewWithStyle:UITableViewStylePlain];
}

+ (UITableView *)tableViewWithStyle:(UITableViewStyle)style
{
    UITableView *tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:style] autorelease];
    tableView.rowHeight = 60.0f;
    return tableView;
}

+ (UIButton *)button
{
    UIButton *button = [[UIButton new] autorelease];
    return button;
}

+ (UIButton *)buttonWithType:(UIButtonType)buttonType
{
    UIButton *button = [UIButton buttonWithType:buttonType];
    
    return button;
}

+ (UILabel *)label
{
    UILabel *label = [[UILabel new] autorelease];
    label.font = [UIFont systemFontOfSize:14.0f];
    label.backgroundColor = [UIColor clearColor];
    
    return label;
}

+ (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action
{
    UIBarButtonItem *barButtonItem = [[[UIBarButtonItem alloc] initWithTitle:title style:style target:target action:action] autorelease];
    
    return barButtonItem;
}

+ (UIBarButtonItem *)borderedBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    return [self.class barButtonItemWithTitle:title style:UIBarButtonItemStyleBordered target:target action:action];
}

+ (UIBarButtonItem *)barButtonItemSystemItem:(UIBarButtonSystemItem)sysItem target:(id)target action:(SEL)action
{
    UIBarButtonItem *barButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:sysItem target:target action:action] autorelease];
    
    return barButtonItem;
}

+ (UIBarButtonItem *)barButtonItemSystemItemFlexibleSpace
{
    return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
}

+ (UITextView *)textView
{
    UITextView *textView = [[UITextView new] autorelease];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    [textView setDraw:YES];
    
    return textView;
}

+ (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier
{
    return [self.class tableViewCellWithReuseIdentifier:identifier style:UITableViewCellStyleDefault];
}

+ (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier style:(UITableViewCellStyle)style
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];
    
    return cell;
}

+ (UIToolbar *)toolbar
{
    UIToolbar *toolbar = [[UIToolbar new] autorelease];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        toolbar.barStyle = UIBarStyleBlack;
    }
    return toolbar;
}

+ (UIToolbar *)toolbarWithPosition:(UIToolbarPosition)position
{
    return [self.class toolbar];
}

+ (UINavigationBar *)navigationBar
{
    UINavigationBar *navigationBar = [[UINavigationBar new] autorelease];
    
    return navigationBar;
}

+ (UIView *)view
{
    UIView *view = [[UIView new] autorelease];
    
    return view;
}

+ (UITextField *)textField
{
    UITextField *textField = [[UITextField new] autorelease];
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    return textField;
}

+ (UIWebView *)webView
{
    UIWebView *webView = [[UIWebView new] autorelease];
    
    return webView;
}

+ (UISearchBar *)searchBar
{
    return [self.class searchBarWithTransparentBackground:NO];
}

+ (UISearchBar *)searchBarWithTransparentBackground:(BOOL)transparentBackground
{
    UISearchBar *searchBar = [[UISearchBar new] autorelease];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.tintColor = [UIColor clearColor];
    
    if(transparentBackground){
        for(UIView *subview in [searchBar subviews]){
            if([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]){
                [subview removeFromSuperview];
            }
        }
    }
    
    return searchBar;
}

+ (UISearchBar *)searchBarWithTransparentBackground
{
    return [self.class searchBarWithTransparentBackground:YES];
}

@end
