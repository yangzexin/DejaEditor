//
//  ScriptAPIDocumentFactory.m
//  CodeEditor
//
//  Created by yangzexin on 2/19/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "DEScriptAPIDocumentFactory.h"
#import "DESourceAPIDocument.h"

@implementation DEScriptAPIDocumentFactory

+ (id<DEScriptAPIDocument>)scriptAPIDocument
{
    return [[DESourceAPIDocument new] autorelease];
}

@end
