//
//  StringPositionFinder.h
//  CodeEditor
//
//  Created by yangzexin on 13-2-26.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DEStringPosition;

@protocol DEStringPositionFinder <NSObject>

- (NSArray *)stringPositionListWithString:(NSString *)string matching:(NSString *)matching isCaseSensitive:(BOOL)isCaseSensitive;
- (DEStringPosition *)currentPosition;
- (DEStringPosition *)nextPosition;
- (DEStringPosition *)previousPosition;
- (DEStringPosition *)beginPosition;
- (DEStringPosition *)endPosition;
- (void)reset;
- (NSInteger)numberOfPositions;
- (NSInteger)currentPositionIndex;

@end

@interface StringPositionFinder : NSObject <DEStringPositionFinder>

@property(nonatomic, assign)BOOL isCaseSensitive;

@end