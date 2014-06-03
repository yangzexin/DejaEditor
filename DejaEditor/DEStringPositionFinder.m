//
//  StringPositionFinder.m
//  CodeEditor
//
//  Created by yangzexin on 13-2-26.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "DEStringPositionFinder.h"
#import "NSString+SVJavaLikeStringHandle.h"
#import "DEStringPosition.h"

@interface StringPositionFinder ()

@property(nonatomic, retain)NSArray *findedStringPositionList;
@property(nonatomic, assign)NSInteger currentPositionIndex;

@end

@implementation StringPositionFinder

- (void)dealloc
{
    self.findedStringPositionList = nil;
    [super dealloc];
}

- (NSArray *)stringPositionListWithString:(NSString *)string matching:(NSString *)matching isCaseSensitive:(BOOL)isCaseSensitive
{
    NSMutableArray *positionList = [NSMutableArray array];
    NSInteger beginIndex = 0;
    NSInteger endIndex = 0;
    while((beginIndex = [string sv_find:matching fromIndex:endIndex reverse:NO isCaseSensitive:isCaseSensitive]) != -1){
        endIndex = beginIndex + matching.length;
        DEStringPosition *tmpStrPosition = [DEStringPosition createWithPosition:beginIndex string:matching];
        [positionList addObject:tmpStrPosition];
    }
    self.findedStringPositionList = positionList;
    self.currentPositionIndex = -1;
    return positionList;
}

- (DEStringPosition *)currentPosition
{
    if(self.findedStringPositionList.count != 0){
        if(self.currentPositionIndex < 0){
            self.currentPositionIndex = 0;
        }
        return [self.findedStringPositionList objectAtIndex:self.currentPositionIndex];
    }
    return nil;
}

- (DEStringPosition *)nextPosition
{
    if(self.findedStringPositionList.count != 0 && self.currentPositionIndex != [self.findedStringPositionList count] - 1){
        ++self.currentPositionIndex;
    }
    return [self currentPosition];
}

- (DEStringPosition *)previousPosition
{
    if(self.findedStringPositionList.count != 0 && self.currentPositionIndex != 0){
        --self.currentPositionIndex;
    }
    return [self currentPosition];
}

- (DEStringPosition *)beginPosition
{
    self.currentPositionIndex = 0;
    return [self currentPosition];
}

- (DEStringPosition *)endPosition
{
    if(self.findedStringPositionList.count != 0){
        self.currentPositionIndex = [self.findedStringPositionList count] - 1;
    }
    return [self currentPosition];
}

- (void)reset
{
    self.findedStringPositionList = nil;
    self.currentPositionIndex = -1;
}

- (NSInteger)numberOfPositions
{
    return self.findedStringPositionList.count;
}

@end