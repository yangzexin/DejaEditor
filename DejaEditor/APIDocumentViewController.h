//
//  APIDocumentViewController.h
//  CodeEditor
//
//  Created by yangzexin on 13-2-20.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseSearchViewController.h"

@interface APIDocumentViewController : BaseSearchViewController

@property(nonatomic, copy)void(^insertTextBlock)(NSString *text);

@end
