//
//  FunctionPosition.h
//  CodeEditor
//
//  Created by yangzexin on 2/25/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DEFunctionPosition : NSObject

@property(nonatomic, copy)NSString *functionName;
@property(nonatomic, assign)NSInteger location;

+ (id)createWithFunctionName:(NSString *)functionName location:(NSInteger)location;

@end
