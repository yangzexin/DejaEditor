//
//  APIClassViewController.h
//  CodeEditor
//
//  Created by yangzexin on 13-2-20.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseSearchViewController.h"

@protocol ScriptAPIDocument;

@interface APIClassViewController : BaseSearchViewController

@property(nonatomic, copy)void(^insertTextBlock)(NSString *text);
- (id)initWithClassName:(NSString *)className methodList:(NSArray *)methodList;

@end
