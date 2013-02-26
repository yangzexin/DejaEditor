//
//  LogView.h
//  GoogleMapLocation
//
//  Created by gewara on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogView : NSObject {
    UITextView *_textView;
    
    BOOL _lock;
}

+ (LogView *)sharedInstance;
- (void)log:(NSString *)log;
- (void)clear;
- (void)setHidden:(BOOL)hidden;
- (BOOL)hidden;

#define VLog(...) [[LogView sharedInstance] log:[NSString stringWithFormat:__VA_ARGS__]]

@end
