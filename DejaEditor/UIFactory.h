//
//  UIFactory.h
//  DejaEditor
//
//  Created by yangzexin on 13-2-27.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIFactory : NSObject

+ (UITableView *)tableView;
+ (UITableView *)tableViewWithStyle:(UITableViewStyle)style;
+ (UIButton *)button;
+ (UIButton *)buttonWithType:(UIButtonType)buttonType;
+ (UILabel *)label;
+ (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)barButtonItemSystemItem:(UIBarButtonSystemItem)sysItem target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)borderedBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)barButtonItemSystemItemFlexibleSpace;
+ (UITextView *)textView;
+ (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier;
+ (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier style:(UITableViewCellStyle)style;
+ (UIToolbar *)toolbar;
+ (UIToolbar *)toolbarWithPosition:(UIToolbarPosition)position;
+ (UINavigationBar *)navigationBar;
+ (UIView *)view;
+ (UITextField *)textField;
+ (UIWebView *)webView;
+ (UISearchBar *)searchBar;
+ (UISearchBar *)searchBarWithTransparentBackground;

@end
