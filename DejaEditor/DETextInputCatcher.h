//
//  TextInputCatcher.h
//  CodeEditor
//
//  Created by yangzexin on 13-2-21.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DETextInputCatcher : NSObject

- (id)initWithWaitingInterval:(NSTimeInterval)waitingInterval;

- (void)mark;
- (void)start:(void(^)())textInputCatchBlock;

@end
