//
//  ScriptAPIDocumentFactory.h
//  CodeEditor
//
//  Created by yangzexin on 2/19/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DEScriptAPIDocument;

@interface DEScriptAPIDocumentFactory : NSObject

+ (id<DEScriptAPIDocument>)scriptAPIDocument;

@end
