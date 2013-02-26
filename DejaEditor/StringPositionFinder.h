//
//  StringPositionFinder.h
//  CodeEditor
//
//  Created by yangzexin on 13-2-26.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StringPosition;

@protocol StringPositionFinder <NSObject>

- (NSArray *)stringPositionListWithString:(NSString *)string matching:(NSString *)matching isCaseSensitive:(BOOL)isCaseSensitive;
- (StringPosition *)currentPosition;
- (StringPosition *)nextPosition;
- (StringPosition *)previousPosition;
- (StringPosition *)beginPosition;
- (StringPosition *)endPosition;
- (void)reset;
- (NSInteger)numberOfPositions;
- (NSInteger)currentPositionIndex;

@end

@interface StringPositionFinder : NSObject <StringPositionFinder>

@property(nonatomic, assign)BOOL isCaseSensitive;

@end