//
//  TextInputCatcher.m
//  CodeEditor
//
//  Created by yangzexin on 13-2-21.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "TextInputCatcher.h"
#import "DelayControl.h"

@interface TextInputCatcher ()

@property(nonatomic, copy)void(^textInputCatchBlock)();
@property(nonatomic, assign)NSTimeInterval waitingInterval;
@property(nonatomic, retain)DelayControl *delayControl;

@end

@implementation TextInputCatcher

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
    self.delayControl = [[[DelayControl alloc] initWithInterval:self.waitingInterval completion:^{
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
