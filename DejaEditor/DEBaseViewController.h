//
//  BaseViewController.h
//  VOA
//
//  Created by yangzexin on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProviderPool.h"

@interface DEBaseViewController : UIViewController

- (void)addProviderToPool:(id<SVProviderPoolable>)provider;
- (UIView *)customTitleView;

@end
