//
//  Pretype.h
//  CodeEditor
//
//  Created by yangzexin on 2/21/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DEPretype : NSObject

+ (id)createWithText:(NSString *)text;
+ (id)createWithText:(NSString *)text additionalText:(NSString *)additionalText;

@property(nonatomic, copy)NSString *text;
@property(nonatomic, readonly)NSString *lowerText;
@property(nonatomic, copy)NSString *additionalText;

@end
