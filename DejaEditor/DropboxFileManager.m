//
//  DropboxFileManager.m
//  DejaEditor
//
//  Created by yangzexin on 13-4-18.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "DropboxFileManager.h"
#import <Dropbox/Dropbox.h>

@implementation DropboxFileManager

- (id)init
{
    self = [super init];
    
    DBAccountManager *accountMgr = [[[DBAccountManager alloc] initWithAppKey:@"9dqcnkvgcm47p6k" secret:@"ioumiuk6vjwoqlo"] autorelease];
    [DBAccountManager setSharedManager:accountMgr];
    
    return self;
}

@end
