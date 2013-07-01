//
//  TestVC.m
//  DejaEditor
//
//  Created by yangzexin on 3/10/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "TestHookVC.h"
#import <objc/runtime.h>

typedef void(*UIViewController_viewDidLoad_like_method) (id self, SEL cmd);

static UIViewController_viewDidLoad_like_method original_viewDidLoad;

void replace_viewDidLoad(id self, SEL cmd)
{
    NSLog(@"viewDidLoad:%@", self);
    original_viewDidLoad(self, cmd);
}

@implementation TestHookVC

+ (void)hook:(TestHookVC *)vc
{
    Method method = class_getInstanceMethod([vc class], @selector(viewDidLoad));
    original_viewDidLoad = (UIViewController_viewDidLoad_like_method)method_setImplementation(method, (IMP)replace_viewDidLoad);
}

@end
