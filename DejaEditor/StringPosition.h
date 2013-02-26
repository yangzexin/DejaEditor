//
//  StringPosition.h
//  CodeEditor
//
//  Created by yangzexin on 2/24/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringPosition : NSObject

+ (id)createWithPosition:(NSInteger)position string:(NSString *)string;

@property(nonatomic, assign)NSInteger position;
@property(nonatomic, copy)NSString *string;

@end
