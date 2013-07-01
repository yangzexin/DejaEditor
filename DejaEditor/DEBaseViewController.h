//
//  BaseViewController.h
//  VOA
//
//  Created by yangzexin on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXProviderPool.h"

@interface DEBaseViewController : UIViewController

- (void)addProviderToPool:(id<YXProviderPoolable>)provider;
- (UIView *)customTitleView;

@end
