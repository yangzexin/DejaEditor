//
//  ArrayMethodFinder.m
//  CodeEditor
//
//  Created by yangzexin on 13-2-21.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "DEArrayMethodFinder.h"
#import "DEScriptAPIDocument.h"
#import "DEScriptAPIDocumentFactory.h"
#import "DEPretype.h"
#import "NSString+JavaLikeStringHandle.h"
#import "SVLuaCommonUtils.h"
#import "DEProject.h"
#import "SVClassDefineReplaceChecker.h"
#import "DEFunctionPosition.h"

#define kMethodTypeInstanceMethod 0
#define kMethodTypeClassMethod 1
#define kMethodTypeCommonFunction 2

@interface DEArrayMethodFinder ()

@property(nonatomic, retain)NSMutableArray *instanceMethodList; // auto-generated instance method by analyse script
@property(nonatomic, retain)NSMutableArray *classMethodList; // auto-generated class method by analyse script
@property(nonatomic, retain)NSMutableArray *commonPretypeList; // auto-generated common pretype list by analyse script
@property(nonatomic, retain)NSMutableArray *instanceMethodListRaw;
@property(nonatomic, retain)NSMutableArray *classMethodListRaw;
@property(nonatomic, retain)NSMutableArray *commonPretypeListRaw;
@property(nonatomic, retain)NSMutableArray *highlightPretypeTextListRaw;
@property(nonatomic, retain)NSMutableArray *highlightPretypeText;
@property(nonatomic, retain)NSMutableArray *localVarNameList;
@property(nonatomic, assign)BOOL analyzing;

@property(nonatomic, retain)NSArray *cachedFunctionPositionList;

@end

@implementation DEArrayMethodFinder

- (void)dealloc
{
    self.instanceMethodList = nil;
    self.classMethodList = nil;
    self.commonPretypeList = nil;
    self.instanceMethodListRaw = nil;
    self.classMethodListRaw = nil;
    self.commonPretypeListRaw = nil;
    self.cachedFunctionPositionList = nil;
    self.highlightPretypeTextListRaw = nil;
    self.highlightPretypeText = nil;
    self.localVarNameList = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    id<DEScriptAPIDocument> scriptDoc = [DEScriptAPIDocumentFactory scriptAPIDocument];
    
    self.commonPretypeListRaw = [NSMutableArray arrayWithArray:@[[DEPretype createWithText:@"function "],
                              [DEPretype createWithText:@"for "],
                              [DEPretype createWithText:@"while"],
                              [DEPretype createWithText:@"if "],
                              [DEPretype createWithText:@"then"],
                              [DEPretype createWithText:@"elseif"],
                              [DEPretype createWithText:@"else"],
                              [DEPretype createWithText:@"require \"\""],
                              [DEPretype createWithText:@"repeat"],
                              [DEPretype createWithText:@"self"],
                              [DEPretype createWithText:@"self:id()"],
                              [DEPretype createWithText:@"super"],
                              [DEPretype createWithText:@"print(output)"],
                              [DEPretype createWithText:@"end"],
                              [DEPretype createWithText:@"local "],
                              [DEPretype createWithText:@"nil"],
                              [DEPretype createWithText:@"main()"],
                              [DEPretype createWithText:@"setmetatable(srcTbl, desTbl)"],
                              [DEPretype createWithText:@"getmetatable(tbl)"],
                              [DEPretype createWithText:@"toObjCBool(b)"],
                              [DEPretype createWithText:@"toLuaBool(b)"],
                              [DEPretype createWithText:@"stringSplit(str, split_str)"],
                              [DEPretype createWithText:@"stringTableToNumberTable(tbl)"],
                              [DEPretype createWithText:@"safety_release(obj)"],
                              [DEPretype createWithText:@"safety_release_list(list)"],
                              [DEPretype createWithText:@"isObjCObject()"],
                              [DEPretype createWithText:@"object_type_covert(obj, desClass)"],
                              [DEPretype createWithText:@"and "],
                              [DEPretype createWithText:@"or "],
                              [DEPretype createWithText:@"not "],
                              [DEPretype createWithText:@"true"],
                              [DEPretype createWithText:@"false"],
                              [DEPretype createWithText:@"return ;"],
                              [DEPretype createWithText:@"tonumber(str)"],
                              [DEPretype createWithText:@"runtime::invokeMethod(objId, methodName, ...--[[params]])"],
                              [DEPretype createWithText:@"runtime::invokeClassMethod(className, methodName, ...--[[params]])"],
                              [DEPretype createWithText:@"string::invokeMethod(objId, methodName, ...--[[params]])"],
                              [DEPretype createWithText:@"math::bitOr(...)"],
                              [DEPretype createWithText:@"math::bitAnd(...)"],
                              [DEPretype createWithText:@"math::bitXor(i,j)"],
                              [DEPretype createWithText:@"math::bitNot(i)"],
                              [DEPretype createWithText:@"math::bitLeftshift(i, p)"],
                              [DEPretype createWithText:@"math::bitRightshift(i, p)"],
                              [DEPretype createWithText:@"class(class, baseClass--[[option]])" additionalText:@"define new class"],
                              [DEPretype createWithText:@"toCStruct(...)"]
                              ]];
    
    NSMutableArray *tmpInstanceMethodList = [NSMutableArray array];
    NSMutableArray *tmpClassMethodList = [NSMutableArray array];
    [tmpClassMethodList addObject:[DEPretype createWithText:@"__index"]];
    
    self.highlightPretypeTextListRaw = [NSMutableArray array];
    
    for(NSString *className in [scriptDoc classList]){
        [self.commonPretypeListRaw addObject:[DEPretype createWithText:className]];
        [self.highlightPretypeTextListRaw addObject:className];
        for(NSString *methodName in [scriptDoc methodListWithClassName:className]){
            if([methodName hasPrefix:@"."]){
                methodName = [methodName substringFromIndex:1];
                [tmpClassMethodList addObject:[DEPretype createWithText:methodName additionalText:className]];
            }else{
                methodName = [methodName substringFromIndex:1];
                [tmpInstanceMethodList addObject:[DEPretype createWithText:methodName additionalText:className]];
            }
        }
    }
    self.instanceMethodListRaw = tmpInstanceMethodList;
    self.classMethodListRaw = tmpClassMethodList;
    
    return self;
}

- (id)initWithProject:(id<DEProject>)project scriptName:(NSString *)scriptName
{
    self = [self init];
    
    [self analyzeProject:project exceptedScriptName:scriptName];
    for(id<DEProject> linkedProject in [project linkedProjectList]){
        [self analyzeProject:linkedProject exceptedScriptName:@"main"];
    }
    
    return self;
}

- (NSArray *)findWithList:(NSArray *)list rawList:(NSArray *)rawList textPrefix:(NSString *)textPrefix
{
    textPrefix = [textPrefix lowercaseString];
    NSMutableArray *tmpMethodList = [NSMutableArray array];
    for(NSInteger i = 0; i < rawList.count; ++i){
        DEPretype *tmpPretype = [rawList objectAtIndex:i];
        if([tmpPretype.lowerText hasPrefix:textPrefix]){
            [tmpMethodList addObject:tmpPretype];
        }
    }
    for(NSInteger i = 0; i < list.count; ++i){
        DEPretype *tmpPretype = [list objectAtIndex:i];
        if([tmpPretype.lowerText hasPrefix:textPrefix]){
            [tmpMethodList addObject:tmpPretype];
        }
    }
    return tmpMethodList;
}

- (NSArray *)findInstanceMethodListWithPrefix:(NSString *)textPrefix
{
    return [self findWithList:self.instanceMethodList rawList:self.instanceMethodListRaw textPrefix:textPrefix];
}

- (NSArray *)findClassMethodListWithPrefix:(NSString *)textPrefix
{
    return [self findWithList:self.classMethodList rawList:self.classMethodListRaw textPrefix:textPrefix];
}

- (NSArray *)findCommonPretypeListWithPrefix:(NSString *)textPrefix
{
    return [self findWithList:self.commonPretypeList rawList:self.commonPretypeListRaw textPrefix:textPrefix];
}

- (void)findInstanceMethodListWithPrefix:(NSString *)textPrefix completion:(void(^)(NSArray *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(self.analyzing){}
        self.analyzing = YES;
        NSArray *methodList = [self findInstanceMethodListWithPrefix:textPrefix];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(methodList);
        });
        self.analyzing = NO;
    });
}

- (void)findClassMethodListWithPrefix:(NSString *)textPrefix completion:(void(^)(NSArray *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(self.analyzing){}
        self.analyzing = YES;
        NSArray *methodList = [self findClassMethodListWithPrefix:textPrefix];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(methodList);
        });
        self.analyzing = NO;
    });
}

- (void)findCommonPretypeListWithPrefix:(NSString *)textPrefix completion:(void(^)(NSArray *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(self.analyzing){}
        self.analyzing = YES;
        NSArray *methodList = [self findCommonPretypeListWithPrefix:textPrefix];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(methodList);
        });
        self.analyzing = NO;
    });
}

- (NSArray *)instanceMethods
{
    return self.instanceMethodList;
}

- (NSArray *)classMethods
{
    return self.classMethodList;
}

- (NSArray *)commonPretypes
{
    self.analyzing = YES;
    NSMutableArray *tmpArray = [NSMutableArray array];
    [tmpArray addObjectsFromArray:self.highlightPretypeTextListRaw];
    [tmpArray addObjectsFromArray:self.highlightPretypeText];
    self.analyzing = NO;
    return tmpArray;
}

- (void)analyzeFunctionRelatedWithScript:(NSString *)script
                  outClassMethodNameList:(NSArray **)outClassMethodNameList
               outInstanceMethodNameList:(NSArray **)outInstanceMethodNameList
                     outFunctionNameList:(NSArray **)outFunctionNameList
                    outFunctionParamList:(NSArray **)outFunctionParamList
                 outFunctionPositionList:(NSArray **)outFunctionPositionList
{
    NSString *matching = @"function ";
    NSInteger beginIndex = 0;
    NSInteger endIndex = 0;
    NSMutableArray *tmpClassMethodNameList = [NSMutableArray array];
    NSMutableArray *tmpInstanceMethodNameList = [NSMutableArray array];
    NSMutableArray *tmpFunctionNameList = [NSMutableArray array];
    NSMutableArray *tmpFunctionParamList = [NSMutableArray array];
    NSMutableArray *tmpFunctionPositionList = [NSMutableArray array];
    while((beginIndex = [script find:matching fromIndex:endIndex]) != -1){
        endIndex = [script find:@")" fromIndex:beginIndex];
        if(endIndex != -1){
            NSUInteger leftBracketLocation = [script rangeOfString:@"("
                                                           options:NSBackwardsSearch
                                                             range:NSMakeRange(beginIndex + matching.length, endIndex - beginIndex - matching.length)].location;
            if(leftBracketLocation != -1){
                NSString *funcName = [script substringWithBeginIndex:beginIndex + matching.length endIndex:leftBracketLocation];
                funcName = [funcName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSInteger separatorLocation = [funcName find:@":"];
                NSInteger methodType = -1;
                if(separatorLocation != -1){
                    methodType = kMethodTypeInstanceMethod;
                    funcName = [funcName substringWithBeginIndex:separatorLocation + 1 endIndex:funcName.length];
                }else{
                    separatorLocation = [funcName find:@"."];
                    if(separatorLocation != -1){
                        methodType = kMethodTypeClassMethod;
                        funcName = [funcName substringWithBeginIndex:separatorLocation + 1 endIndex:funcName.length];
                    }else{
                        methodType = kMethodTypeCommonFunction;
                    }
                }
                if([SVLuaCommonUtils isAlphbelts:funcName]){
                    NSString *funcParamsWithBracket = [script substringWithBeginIndex:leftBracketLocation endIndex:endIndex + 1];
                    funcName = [NSString stringWithFormat:@"%@%@", funcName, funcParamsWithBracket];
                    DEFunctionPosition *tmpFP = [DEFunctionPosition createWithFunctionName:[script substringWithBeginIndex:beginIndex endIndex:endIndex + 1]
                                                                              location:beginIndex];
                    [tmpFunctionPositionList addObject:tmpFP];
                    switch (methodType) {
                        case kMethodTypeClassMethod:
                            [tmpClassMethodNameList addObject:funcName];
                            break;
                        case kMethodTypeCommonFunction:
                            [tmpFunctionNameList addObject:funcName];
                        case kMethodTypeInstanceMethod:
                            [tmpInstanceMethodNameList addObject:funcName];
                            break;
                            
                        default:
                            break;
                    }
                    
                    NSString *params = [script substringWithBeginIndex:leftBracketLocation + 1 endIndex:endIndex];
                    NSArray *paramList = [params componentsSeparatedByString:@","];
                    for(NSString *param in paramList){
                        param = [param stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        if(param.length != 0){
                            [tmpFunctionParamList addObject:param];
                        }
                    }
                }
            }
        }else{
            break;
        }
    }
    if(outClassMethodNameList){
        *outClassMethodNameList = tmpClassMethodNameList;
    }
    if(outInstanceMethodNameList){
        *outInstanceMethodNameList = tmpInstanceMethodNameList;
    }
    if(outFunctionNameList){
        *outFunctionNameList = tmpFunctionNameList;
    }
    if(outFunctionParamList){
        *outFunctionParamList = tmpFunctionParamList;
    }
    if(outFunctionPositionList){
//        [tmpFunctionPositionList sortUsingComparator:^NSComparisonResult(DEFunctionPosition *obj1, DEFunctionPosition *obj2) {
//            return [[obj1.functionName lowercaseString] compare:[obj2.functionName lowercaseString]];
//        }];
        *outFunctionPositionList = tmpFunctionPositionList;
    }
}

+ (void)addPretypeTextList:(NSArray *)textList toList:(NSMutableArray *)toList additionText:(NSString *)additionalText
{
    for(NSString *text in textList){
        BOOL exists = NO;
        for(NSInteger i = 0; i < toList.count; ++i){
            DEPretype *tmpPretype = [toList objectAtIndex:i];
            if([tmpPretype.lowerText isEqualToString:[text lowercaseString]]){
                exists = YES;
                break;
            }
        }
        if(!exists){
            [toList addObject:[DEPretype createWithText:text additionalText:additionalText]];
        }
    }
}

- (NSArray *)requireScriptNameListWithScript:(NSString *)script
{
    NSString *matching = @"require ";
    NSInteger beginIndex = 0;
    NSInteger endIndex = 0;
    NSMutableArray *list = [NSMutableArray array];
    while((beginIndex = [script find:matching fromIndex:endIndex]) != -1){
        endIndex = [script find:@"\n" fromIndex:beginIndex];
        if(endIndex != -1){
            NSString *innerText = [script substringWithBeginIndex:beginIndex + matching.length endIndex:endIndex];
            innerText = [innerText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if([innerText hasPrefix:@"\""]){
                innerText = [innerText substringWithBeginIndex:1 endIndex:innerText.length - 1];
                [list addObject:innerText];
            }
        }else{
            break;
        }
    }
    return list;
}

- (NSArray *)classNameListWithScript:(NSString *)script
{
    NSInteger beginIndex = 0;
    NSInteger endIndex = 0;
    NSMutableArray *nameList = [NSMutableArray array];
    while((beginIndex = [script find:@"class" fromIndex:endIndex]) != -1){
        NSInteger leftBracketLocation = [script find:@"(" fromIndex:beginIndex + 5];
        endIndex = [script find:@")" fromIndex:beginIndex + 5];
        if(leftBracketLocation != -1 && endIndex != -1){
            NSString *leftInnerText = [script substringWithBeginIndex:beginIndex + 5 endIndex:leftBracketLocation];
            leftInnerText = [leftInnerText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *paramText = [script substringWithBeginIndex:leftBracketLocation + 1 endIndex:endIndex];
            NSString *className = nil;
            NSString *baseClassName = nil;
            if(leftInnerText.length == 0 && [SVClassDefineReplaceChecker paramValid:paramText className:&className baseClassName:&baseClassName]){
                if([SVLuaCommonUtils isAlphbelts:className]){
                    [nameList addObject:className];
                }
            }else{
                break;
            }
        }else{
            break;
        }
    }
    return nameList;
}

- (void)analyzeProject:(id<DEProject>)project exceptedScriptName:(NSString *)scriptName
{
    NSArray *scriptNameList = [project scriptNameList];
    [self.class addPretypeTextList:scriptNameList toList:self.commonPretypeListRaw additionText:@"class name"];
    for(NSString *tmpScriptName in scriptNameList){
        if(![tmpScriptName isEqualToString:scriptName]){
            NSMutableArray *tmpOtherClassMethodNameList = nil;
            NSMutableArray *tmpOtherInstanceMethodNameList = nil;
            NSMutableArray *tmpOtherFunctionNameList = nil;
            NSString *script = [project scriptContentWithName:tmpScriptName];
            [self analyzeFunctionRelatedWithScript:script
                            outClassMethodNameList:&tmpOtherClassMethodNameList
                         outInstanceMethodNameList:&tmpOtherInstanceMethodNameList
                               outFunctionNameList:&tmpOtherFunctionNameList
                              outFunctionParamList:nil
                           outFunctionPositionList:nil];
            [self.class addPretypeTextList:tmpOtherClassMethodNameList
                                    toList:self.classMethodListRaw
                              additionText:[NSString stringWithFormat:@"%@ class method", tmpScriptName]];
            [self.class addPretypeTextList:[self classNameListWithScript:script]
                                    toList:self.classMethodListRaw
                              additionText:[NSString stringWithFormat:@"%@ class name", tmpScriptName]];
            [self.class addPretypeTextList:tmpOtherInstanceMethodNameList
                                    toList:self.instanceMethodListRaw
                              additionText:[NSString stringWithFormat:@"%@ instance method", tmpScriptName]];
            [self.class addPretypeTextList:tmpOtherFunctionNameList
                                    toList:self.commonPretypeListRaw
                              additionText:[NSString stringWithFormat:@"%@ function", tmpScriptName]];
        }
    }
}

- (void)analyzeWithScriptName:(NSString *)scriptName script:(NSString *)script project:(id<DEProject>)project
{
    if(self.analyzing){
        return;
    }
    self.instanceMethodList = [NSMutableArray array];
    self.classMethodList = [NSMutableArray array];
    self.commonPretypeList = [NSMutableArray array];
    self.highlightPretypeText = [NSMutableArray array];
    self.localVarNameList = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *tmpClassMethodNameList = nil;
        NSMutableArray *tmpFuncParamList = nil;
        NSMutableArray *tmpInstanceMethodNameList = nil;
        NSMutableArray *tmpFunctionNameList = nil;
        NSMutableArray *tmpFunctionPositionList = nil;
        [self analyzeFunctionRelatedWithScript:script
                        outClassMethodNameList:&tmpClassMethodNameList
                     outInstanceMethodNameList:&tmpInstanceMethodNameList
                           outFunctionNameList:&tmpFunctionNameList
                          outFunctionParamList:&tmpFuncParamList
                       outFunctionPositionList:&tmpFunctionPositionList];
        self.cachedFunctionPositionList = tmpFunctionPositionList;
        NSArray *tmpClassNameList = [self classNameListWithScript:script];
        
        // analyse local variables
        NSMutableArray *tmpLocalVarNameList = [NSMutableArray array];
        NSInteger beginIndex = 0;
        NSInteger endIndex = 0;
        NSString *matching = @"local ";
        while((beginIndex = [script find:matching fromIndex:endIndex]) != -1){
            NSInteger assignPosition = [script find:@"=" fromIndex:beginIndex];
            NSInteger endPosition = [script find:@";" fromIndex:beginIndex];
            if(assignPosition == -1){
                endIndex = endPosition;
            }else if(endPosition == -1){
                endIndex = assignPosition;
            }else{
                endIndex = MIN(assignPosition, endPosition);
            }
            if(endIndex != -1){
                NSString *varName = [script substringWithBeginIndex:beginIndex + 6 endIndex:endIndex];
                varName = [varName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if([SVLuaCommonUtils isAlphbelts:varName] && ![tmpLocalVarNameList containsObject:varName]){
                    [tmpLocalVarNameList addObject:varName];
                }else if([varName rangeOfString:@","].location != NSNotFound){
                    NSArray *varNameList = [varName componentsSeparatedByString:@","];
                    for(NSString *tmpVarName in varNameList){
                        tmpVarName = [tmpVarName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        if([SVLuaCommonUtils isAlphbelts:tmpVarName] && ![tmpLocalVarNameList containsObject:tmpVarName]){
                            [tmpLocalVarNameList addObject:tmpVarName];
                        }
                    }
                }
            }else{
                break;
            }
        }
        if(tmpFuncParamList.count != 0){
            [tmpLocalVarNameList addObjectsFromArray:tmpFuncParamList];
        }
        [self.localVarNameList addObjectsFromArray:tmpLocalVarNameList];
        if(tmpClassNameList.count != 0){
            [tmpLocalVarNameList addObjectsFromArray:tmpClassNameList];
            [self.highlightPretypeText addObjectsFromArray:tmpClassNameList];
        }
        // add all local var as common pretype
        [self.class addPretypeTextList:tmpLocalVarNameList toList:self.commonPretypeList additionText:@"local variable"];
        
        if(tmpFunctionNameList.count != 0){
            [self.class addPretypeTextList:tmpFunctionNameList toList:self.commonPretypeList additionText:@"local function"];
            [self.highlightPretypeText addObjectsFromArray:tmpFunctionNameList];
        }
        if(tmpClassMethodNameList.count != 0){
            [self.class addPretypeTextList:tmpClassMethodNameList toList:self.classMethodList additionText:@"local class method"];
        }
        
        // find all local variable's instance variables
        NSMutableArray *tmpSubVarNameList = [NSMutableArray array];
        [tmpLocalVarNameList addObject:@"self"];
        for(NSString *varName in tmpLocalVarNameList){
            varName = [NSString stringWithFormat:@"%@.", varName];
            beginIndex = 0;
            endIndex = 0;
            while((beginIndex = [script find:varName fromIndex:endIndex]) != -1){
                endIndex = [script find:@"=" fromIndex:beginIndex];
                if(endIndex != -1){
                    NSString *subVarName = [script substringWithBeginIndex:beginIndex + varName.length endIndex:endIndex];
                    subVarName = [subVarName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    endIndex = beginIndex + varName.length;
                    if([SVLuaCommonUtils isAlphbelts:subVarName] && ![tmpSubVarNameList containsObject:subVarName]){
                        [tmpSubVarNameList addObject:subVarName];
                    }
                }else{
                    break;
                }
            }
        }
        // add all sub var as class method pretype
        [self.class addPretypeTextList:tmpSubVarNameList toList:self.classMethodList additionText:@"local instance variable"];
        
        if(tmpInstanceMethodNameList.count != 0){
            // add all instance method name as instance method pretype
            [self.class addPretypeTextList:tmpInstanceMethodNameList toList:self.instanceMethodList additionText:@"local instance method"];
        }
        
        self.analyzing = NO;
    });
}

@end
