//
//  BaseViewController.h
//  VOA
//
//  Created by yangzexin on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProviderPool.h"

@interface DEBaseViewController : UIViewController

- (void)addProviderToPool:(id<ProviderPoolable>)provider;
- (UIView *)customTitleView;

@end
