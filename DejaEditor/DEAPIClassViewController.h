//
//  APIClassViewController.h
//  CodeEditor
//
//  Created by yangzexin on 13-2-20.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DEBaseSearchViewController.h"

@protocol DEScriptAPIDocument;

@interface DEAPIClassViewController : DEBaseSearchViewController

@property(nonatomic, copy)void(^insertTextBlock)(NSString *text);
- (id)initWithClassName:(NSString *)className methodList:(NSArray *)methodList;

@end
