//
//  TextInputCatcher.m
//  CodeEditor
//
//  Created by yangzexin on 13-2-21.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "DETextInputCatcher.h"
#import "YXDelayControl.h"

@interface DETextInputCatcher ()

@property(nonatomic, copy)void(^textInputCatchBlock)();
@property(nonatomic, assign)NSTimeInterval waitingInterval;
@property(nonatomic, retain)YXDelayControl *delayControl;

@end

@implementation DETextInputCatcher

- (void)dealloc
{
    self.textInputCatchBlock = nil;
    [super dealloc];
}

- (id)initWithWaitingInterval:(NSTimeInterval)waitingInterval
{
    self = [super init];
    
    self.waitingInterval = waitingInterval;
    
    return self;
}

- (void)mark
{
    [self.delayControl cancel];
    self.delayControl = [[[YXDelayControl alloc] initWithInterval:self.waitingInterval completion:^{
        if(self.textInputCatchBlock){
            self.textInputCatchBlock();
        }
    }] autorelease];
    [self.delayControl start];
}

- (void)start:(void(^)())textInputCatchBlock
{
    self.textInputCatchBlock = textInputCatchBlock;
}

@end
