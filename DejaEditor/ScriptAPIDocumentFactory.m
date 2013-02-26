//
//  ScriptAPIDocumentFactory.m
//  CodeEditor
//
//  Created by yangzexin on 2/19/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "ScriptAPIDocumentFactory.h"
#import "SourceAPIDocument.h"

@implementation ScriptAPIDocumentFactory

+ (id<ScriptAPIDocument>)scriptAPIDocument
{
    return [[SourceAPIDocument new] autorelease];
}

@end
