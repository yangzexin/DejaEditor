//
//  EditorViewController.m
//  CodeEditor
//
//  Created by yangzexin on 2/12/13.
//  Copyright (c) 2013 yangzexin. All rights reserved.
//

#import "DEEditorViewController.h"
#import "SVLuaCommonUtils.h"
#import "SVAlertDialog.h"
#import "DEAPIDocumentViewController.h"
#import "DEMethodFinder.h"
#import "DEMethodFinderFactory.h"
#import "DETextInputCatcher.h"
#import "SVLuaCommonUtils.h"
#import "SVDelayControl.h"
#import "DEPretype.h"
#import "NSString+SVJavaLikeStringHandle.h"
#import "DEStringPosition.h"
#import "LogView.h"
#import "SVUITools.h"
#import "DEFunctionPosition.h"
#import <QuartzCore/QuartzCore.h>
#import "QRFindReplaceView.h"
#import "DEStringPositionFinder.h"
#import "DEColorfulTextView.h"
#import "NSAttributedString+TextColor.h"
#import "DESimpleColorfulTextView.h"

#define kTextViewActionInsert   1
#define kTextViewActionRemove   2

#define kMethodInvokeViaNone       0
#define kMethodInvokeViaDot        1
#define kMethodInvokeViaColon      2

@interface DEEditorViewController () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, QRFindReplaceViewDelegate>

@property(nonatomic, retain)id<DEProject> project;
@property(nonatomic, retain)NSString *scriptName;

@property(nonatomic, retain)UITextView *textView;
@property(nonatomic, assign)NSInteger textViewLastAction;
@property(nonatomic, retain)UIView *keyboardToolsView;
@property(nonatomic, retain)UIPopoverController *docPopoverController;
@property(nonatomic, retain)UIViewController *docViewController;
@property(nonatomic, retain)id<DEMethodFinder> methodFinder;
@property(nonatomic, retain)DETextInputCatcher *textInputCatcher;
@property(nonatomic, assign)NSInteger currentMethodInvokeVia;
@property(nonatomic, assign)NSInteger currentInvokePosition;
@property(nonatomic, assign)NSInteger currentInvokeCaretLocation;
@property(nonatomic, retain)UITableView *pretypeSelectionListTableView;
@property(nonatomic, retain)UIView *pretypeSelectionListTableViewShadowView;
@property(nonatomic, retain)NSArray *pretypeSelectionList;
@property(nonatomic, retain)SVDelayControl *delayControlForAnalyzer;
@property(nonatomic, retain)UIToolbar *bottomToolbar;
@property(nonatomic, retain)UIToolbar *topToolbar;
@property(nonatomic, retain)UIBarButtonItem *showTopBarButton;
@property(nonatomic, retain)NSArray *functionPositionList;
@property(nonatomic, retain)UITableView *functionPositionListTableView;
@property(nonatomic, retain)UIView *functionPositionListTableViewShadowView;
@property(nonatomic, retain)UIBarButtonItem *showFunctionIndexButton;
@property(nonatomic, retain)QRFindReplaceView *findReplaceView;
@property(nonatomic, retain)StringPositionFinder *stringPositionFinder;
@property(nonatomic, retain)DETextInputCatcher *findTextInputCatcher;
@property(nonatomic, retain)DETextInputCatcher *highlightInputCatcher;
@property(nonatomic, retain)DETextInputCatcher *saveInputCatcher;
@property(nonatomic, retain)NSString *lastReplacedText;
@property(nonatomic, retain)UIBarButtonItem *lineNumberLabel;
@property(nonatomic, assign)BOOL blockPretypeAnalyse;

@end

@implementation DEEditorViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.runProjectBlock = nil;
    self.stopRunningBlock = nil;
    
    self.project = nil;
    self.scriptName = nil;
    
    self.textView = nil;
    self.keyboardToolsView = nil;
    self.docPopoverController = nil;
    self.docViewController = nil;
    self.methodFinder = nil;
    self.textInputCatcher = nil;
    self.pretypeSelectionListTableView = nil;
    self.pretypeSelectionListTableViewShadowView = nil;
    self.pretypeSelectionList = nil;
    self.delayControlForAnalyzer = nil;
    self.bottomToolbar = nil;
    self.topToolbar = nil;
    self.showTopBarButton = nil;
    self.functionPositionList = nil;
    self.functionPositionListTableView = nil;
    self.functionPositionListTableViewShadowView = nil;
    self.showFunctionIndexButton = nil;
    self.findReplaceView = nil;
    self.stringPositionFinder = nil;
    self.findTextInputCatcher = nil;
    self.highlightInputCatcher = nil;
    self.saveInputCatcher = nil;
    self.lineNumberLabel = nil;
    [super dealloc];
}

- (id)initWithProject:(id<DEProject>)project scriptName:(NSString *)scriptName
{
    self = [self init];
    
    self.title = scriptName;
    self.project = project;
    self.scriptName = scriptName;
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.textView = [UIFactory textView];
    self.textView.frame = self.view.bounds;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = [UIFont systemFontOfSize:16.0f];
    [self.view addSubview:self.textView];
    
    self.topToolbar = [UIFactory toolbar];
    self.topToolbar.frame = CGRectMake(0, -44, self.view.frame.size.width, 44);
    self.topToolbar.barStyle = UIBarStyleBlack;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        self.topToolbar.barStyle = UIBarStyleDefault;
    }
    self.topToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.topToolbar];
    self.findReplaceView = [[[QRFindReplaceView alloc] initWithFrame:self.topToolbar.bounds] autorelease];
    self.findReplaceView.matchingCountLabel.textColor = [UIColor whiteColor];
    self.findReplaceView.delegate = self;
    [self.topToolbar addSubview:self.findReplaceView];
    
    CGFloat keyboardToolsViewHeight = 44.0f;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        keyboardToolsViewHeight = 60.0f;
    }else{
        self.textView.font = [UIFont systemFontOfSize:10.0f];
        keyboardToolsViewHeight *= 2;
    }
    self.keyboardToolsView = [UIFactory view];
    self.keyboardToolsView.frame = CGRectMake(0, 0, self.view.frame.size.width, keyboardToolsViewHeight);
    self.keyboardToolsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.keyboardToolsView.hidden = YES;
    self.keyboardToolsView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.keyboardToolsView];
    
    UIToolbar *keyboardToolbar = [UIFactory toolbar];
    keyboardToolbar.frame = self.keyboardToolsView.bounds;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        keyboardToolbar.frame = CGRectMake(0, 0, self.keyboardToolsView.frame.size.width, self.keyboardToolsView.frame.size.height / 2);
    }
    keyboardToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    keyboardToolbar.barStyle = UIBarStyleBlackOpaque;
    [self.keyboardToolsView addSubview:keyboardToolbar];
    
    UIBarButtonItem *tabBtn = [UIFactory borderedBarButtonItemWithTitle:@"Tab" target:self action:@selector(tabButtonTapped)];
    UIBarButtonItem *bracketBtn = [UIFactory borderedBarButtonItemWithTitle:@" ( ) " target:self action:@selector(bracketButtonTapped)];
    UIBarButtonItem *bigBracketBtn = [UIFactory borderedBarButtonItemWithTitle:@" { } " target:self action:@selector(bigBracketButtonTapped)];
    UIBarButtonItem *semicolonBtn = [UIFactory borderedBarButtonItemWithTitle:@"  ;  " target:self action:@selector(semicolonButtonTapped)];
    UIBarButtonItem *assignBtn = [UIFactory borderedBarButtonItemWithTitle:@"  =  " target:self action:@selector(assignButtonTapped)];
    UIBarButtonItem *negateBtn = [UIFactory borderedBarButtonItemWithTitle:@" ~= " target:self action:@selector(negateButtonTapped)];
    UIBarButtonItem *quotesBtn = [UIFactory borderedBarButtonItemWithTitle:@" \"\" " target:self action:@selector(quotesButtonTapped)];
    UIBarButtonItem *colonBtn = [UIFactory borderedBarButtonItemWithTitle:@"  :  " target:self action:@selector(colonButtonTapped)];
    UIBarButtonItem *logBtn = [UIFactory borderedBarButtonItemWithTitle:@"log" target:self action:@selector(logButtonTapped)];
    UIBarButtonItem *pasteBtn = [UIFactory borderedBarButtonItemWithTitle:@"Paste" target:self action:@selector(pasteButtonTapped)];
    UIBarButtonItem *delLineBtn = [UIFactory borderedBarButtonItemWithTitle:@"Del" target:self action:@selector(deleteLineButtonTapped)];
    UIBarButtonItem *gotoLineBeginBtn = [UIFactory borderedBarButtonItemWithTitle:@"<-" target:self action:@selector(gotoLineBeginButtonTapped)];
    UIBarButtonItem *gotoLineEndBtn = [UIFactory borderedBarButtonItemWithTitle:@"->" target:self action:@selector(gotoLineEndButtonTapped)];
    UIBarButtonItem *closeKeyboardBtn = [UIFactory barButtonItemSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeKeyboardButtonTapped)];
    self.lineNumberLabel = [UIFactory barButtonItemWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()){
        keyboardToolbar.items = @[tabBtn,
                          bracketBtn,
                          bigBracketBtn,
                          quotesBtn,
                          assignBtn,
                          negateBtn,
                          colonBtn,
                          logBtn,
                          [UIFactory barButtonItemSystemItemFlexibleSpace],
                          self.lineNumberLabel,
                          [UIFactory barButtonItemSystemItemFlexibleSpace],
                          pasteBtn,
                          delLineBtn, 
                          gotoLineBeginBtn,
                          gotoLineEndBtn,
                          semicolonBtn,
                          closeKeyboardBtn
                          ];
    }else{
        keyboardToolbar.items = @[tabBtn,
                          bracketBtn,
                          quotesBtn,
                          assignBtn,
                          semicolonBtn,
                          [UIFactory barButtonItemSystemItemFlexibleSpace],
                          closeKeyboardBtn
                          ];
        UIToolbar *secToolbar = [UIFactory toolbar];
        secToolbar.barStyle = keyboardToolbar.barStyle;
        secToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        secToolbar.frame = CGRectMake(0, keyboardToolbar.frame.size.height, keyboardToolbar.frame.size.width, keyboardToolbar.frame.size.height);
        UIBarButtonItem *dotBtn = [UIFactory borderedBarButtonItemWithTitle:@"." target:self action:@selector(dotButtonTapped)];
        secToolbar.items = @[colonBtn, dotBtn, logBtn, pasteBtn, delLineBtn, gotoLineBeginBtn, gotoLineEndBtn];
        [self.keyboardToolsView addSubview:secToolbar];
    }
    
    self.navigationItem.rightBarButtonItem = [UIFactory barButtonItemSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(runButtonTapped)];
    self.bottomToolbar = [UIFactory toolbar];
    self.bottomToolbar.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    self.bottomToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.bottomToolbar];
    self.bottomToolbar.barStyle = self.navigationController.navigationBar.barStyle;
    self.showTopBarButton = [UIFactory borderedBarButtonItemWithTitle:NSLocalizedString(@"Find & Replace", nil)
                                                               target:self
                                                               action:@selector(showTopBarButtonTapped)];
    self.showFunctionIndexButton = [UIFactory borderedBarButtonItemWithTitle:NSLocalizedString(@"Functions", nil)
                                                                      target:self
                                                                      action:@selector(showFunctionIndexButtonTapped)];
    self.bottomToolbar.items = @[[UIFactory borderedBarButtonItemWithTitle:NSLocalizedString(@"Console", nil)
                                                                    target:self
                                                                    action:@selector(consoleButtonTapped)],
                                 self.showTopBarButton,
                                 [UIFactory barButtonItemSystemItemFlexibleSpace],
                                 self.showFunctionIndexButton,
                                 [UIFactory barButtonItemSystemItemFlexibleSpace],
                                 [UIFactory barButtonItemSystemItem:UIBarButtonSystemItemBookmarks
                                                             target:self
                                                             action:@selector(viewAPIButtonTapped:)]];
    self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.bounds.size.height - 44);
    
    self.pretypeSelectionListTableView = [UIFactory tableView];
    self.pretypeSelectionListTableView.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width / 2, 180);
    self.pretypeSelectionListTableView.delegate = self;
    self.pretypeSelectionListTableView.dataSource = self;
    self.pretypeSelectionListTableView.opaque = NO;
    self.pretypeSelectionListTableView.alpha = 1.0f;
    self.pretypeSelectionListTableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.pretypeSelectionListTableView.rowHeight = 60.0f;
    self.pretypeSelectionListTableView.backgroundColor = [UIColor clearColor];
    self.pretypeSelectionListTableViewShadowView = [[UIView new] autorelease];
    self.pretypeSelectionListTableViewShadowView.backgroundColor = [UIColor whiteColor];
    self.pretypeSelectionListTableViewShadowView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.pretypeSelectionListTableViewShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.pretypeSelectionListTableViewShadowView.layer.shadowOpacity = .20f;
    self.pretypeSelectionListTableViewShadowView.layer.shadowRadius = 1.0f;
    self.pretypeSelectionListTableViewShadowView.layer.shadowOffset = CGSizeMake(-1, 1.0f);
    self.pretypeSelectionListTableViewShadowView.layer.shouldRasterize = YES;
    self.pretypeSelectionListTableViewShadowView.frame = self.pretypeSelectionListTableView.frame;
    [self.view addSubview:self.pretypeSelectionListTableViewShadowView];
    [self.view addSubview:self.pretypeSelectionListTableView];
    [self setPretypeSelectionListTableViewHidden:YES];
    
    self.functionPositionListTableView = [UIFactory tableView];
    self.functionPositionListTableView.frame = CGRectMake(0,
                                                          0,
                                                          self.view.frame.size.width / 2,
                                                          self.view.frame.size.height - self.bottomToolbar.frame.size.height);
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        CGRect tmpRect = self.functionPositionListTableView.frame;
        tmpRect.size.width = self.view.frame.size.width;
        self.functionPositionListTableView.frame = tmpRect;
    }
    self.functionPositionListTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.functionPositionListTableView.delegate = self;
    self.functionPositionListTableView.dataSource = self;
    self.functionPositionListTableView.rowHeight = 60.0f;
    self.functionPositionListTableViewShadowView = [[UIView new] autorelease];
    self.functionPositionListTableViewShadowView.frame = CGRectMake(self.functionPositionListTableView.frame.origin.x + self.functionPositionListTableView.frame.size.width - 5,
                                                                    self.functionPositionListTableView.frame.origin.y, 5,
                                                                    self.functionPositionListTableView.frame.size.height);
    self.functionPositionListTableViewShadowView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    self.functionPositionListTableViewShadowView.backgroundColor = [UIColor whiteColor];
    self.functionPositionListTableViewShadowView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.functionPositionListTableViewShadowView.layer.shadowOpacity = .2f;
    self.functionPositionListTableViewShadowView.layer.shadowRadius = 1.0f;
    self.functionPositionListTableViewShadowView.layer.shouldRasterize = YES;
    [self.view addSubview:self.functionPositionListTableViewShadowView];
    [self.view addSubview:self.functionPositionListTableView];
    [self setFunctionPositionListTableViewHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];
    
    self.textView.text = [self.project scriptContentWithName:self.scriptName];
    
    self.methodFinder = [DEMethodFinderFactory methodFinderWithProject:self.project scriptName:self.scriptName];
    [self startAnalyse];
    self.textInputCatcher = [[[DETextInputCatcher alloc] initWithWaitingInterval:0.50f] autorelease];
    [self.textInputCatcher start:^{
        if(self.blockPretypeAnalyse){
            return ;
        }
        NSString *prefix = nil;
        NSInteger invokePosition = 0;
        NSInteger methodInvokeVia = [self findMethodInvokeAtCaretLocation:self.textView.selectedRange.location
                                                                   inText:self.textView.text
                                                                outPrefix:&prefix
                                                        outInvokePosition:&invokePosition];
        self.currentMethodInvokeVia = methodInvokeVia;
        self.currentInvokePosition = invokePosition;
        self.currentInvokeCaretLocation = self.textView.selectedRange.location;
        if(methodInvokeVia == kMethodInvokeViaColon){
            [self.methodFinder findInstanceMethodListWithPrefix:prefix completion:^(NSArray *selectionList) {
                [self updatePretypeSelectionList:selectionList];
            }];
        }else if(methodInvokeVia == kMethodInvokeViaDot){
            [self.methodFinder findClassMethodListWithPrefix:prefix completion:^(NSArray *selectionList) {
                [self updatePretypeSelectionList:selectionList];
            }];
        }else{
            if(prefix.length != 0){
                [self.methodFinder findCommonPretypeListWithPrefix:prefix completion:^(NSArray *selectionList) {
                    [self updatePretypeSelectionList:selectionList];
                }];
            }
        }
    }];
    self.saveInputCatcher = [[[DETextInputCatcher alloc] initWithWaitingInterval:3.0f] autorelease];
    [self.saveInputCatcher start:^{
        [self saveScript];
    }];
//    if([self.textView respondsToSelector:@selector(setAttributedTextBlock:)]){
//        self.highlightInputCatcher = [[[DETextInputCatcher alloc] initWithWaitingInterval:5.0f] autorelease];
//        [self.highlightInputCatcher start:^{
//            NSRange tmpRange = self.textView.selectedRange;
//            self.textView.text = self.textView.text;
//            if(self.textView.isFirstResponder){
//                BOOL functionTableHidden = self.functionPositionListTableView.hidden;
//                self.textView.selectedRange = NSMakeRange(tmpRange.location, 0);
//                [self.textView insertText:@" "];
//                [self.textView deleteBackward];
//                self.textView.selectedRange = tmpRange;
//                if(functionTableHidden){
//                    self.functionPositionListTableView.hidden = YES;
//                }
//            }
//        }];
//        [((DEColorfulTextView *)self.textView) setAttributedTextBlock:^NSAttributedString *(NSMutableAttributedString *attributedText, NSString *originalText) {
//            NSArray *pretypeList = [self.methodFinder commonPretypes];
//            
//            attributedText = [attributedText setColor:[UIColor colorWithRed:110.f/255.f green:50.f/255.f blue:170.f/255.f alpha:1] words:pretypeList inText:attributedText decideBlock:^BOOL(NSString *word, NSRange range) {
//                return [DEColorfulTextView isStandonlyWord:word inText:originalText range:range];
//            }];
//            
//            NSArray *localVarNameList = [self.methodFinder localVarNameList];
//            attributedText = [attributedText setColor:[UIColor colorWithRed:96.f/255.f green:127.f/255.f blue:134.f/255.f alpha:1] words:localVarNameList inText:attributedText decideBlock:^BOOL(NSString *word, NSRange range) {
//                return [DEColorfulTextView isStandonlyWord:word inText:originalText range:range];
//            }];
//            
//            attributedText = [attributedText setColor:[UIColor redColor] words:@[@":", @"."] inText:attributedText decideBlock:nil];
//            return attributedText;
//        }];
//    }
    if([self.textView respondsToSelector:@selector(setTextDidResetBlock:)]){
        self.highlightInputCatcher = [[[DETextInputCatcher alloc] initWithWaitingInterval:4.0f] autorelease];
        [self.highlightInputCatcher start:^{
            NSRange tmpRange = self.textView.selectedRange;
            self.textView.text = self.textView.text;
            if(self.textView.isFirstResponder){
                BOOL functionTableHidden = self.pretypeSelectionListTableView.hidden;
                self.textView.selectedRange = NSMakeRange(tmpRange.location, 0);
                [self.textView insertText:@" "];
                [self.textView deleteBackward];
                self.textView.selectedRange = tmpRange;
                if(functionTableHidden){
                    [self setPretypeSelectionListTableViewHidden:YES];
                }
            }
        }];
        [((DESimpleColorfulTextView *)self.textView) setTextDidResetBlock:^{
            self.blockPretypeAnalyse = YES;
            [[[[SVDelayControl alloc] initWithInterval:1.0f completion:^{
                self.blockPretypeAnalyse = NO;
            }] autorelease] start];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
    [self saveScript];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.navigationController setToolbarHidden:YES];
}

- (void)screenRotationWillChange
{
}

#pragma mark - private methods
- (void)startAnalyse
{
    [self.methodFinder analyzeWithScriptName:self.scriptName script:self.textView.text project:self.project];
    self.delayControlForAnalyzer = [[[SVDelayControl alloc] initWithInterval:5.0f completion:^{
        [self startAnalyse];
    }] autorelease];
    [self.delayControlForAnalyzer start];
}

- (void)saveScript
{
    [self.project saveScriptWithName:self.scriptName content:self.textView.text];
}

- (NSInteger)findMethodInvokeAtCaretLocation:(NSUInteger)caretLocation
                                      inText:(NSString *)text
                                   outPrefix:(NSString **)outPrefix
                           outInvokePosition:(NSInteger *)outInvokePosition
{
    if(caretLocation == 0){
        return kMethodInvokeViaNone;
    }
    NSArray *blockLeftEdgeList = @[@" ", @"[", @"#", @"=", @"\"", @",", @"(", @";", @"\t", @"\n"];
//    NSUInteger *edgePositionList = malloc(blockLeftEdgeList.count * sizeof(NSUInteger));
    NSInteger maxPosition = 0;
    NSInteger maxPositionIndex = 0;
    for(NSInteger i = 0; i < blockLeftEdgeList.count; ++i){
        NSUInteger edgeIndex = [text rangeOfString:[blockLeftEdgeList objectAtIndex:i] options:NSBackwardsSearch range:NSMakeRange(0, caretLocation)].location;
        edgeIndex = edgeIndex == NSNotFound ? 0 : edgeIndex;
//        *(edgePositionList + i) = edgeIndex;
        if(edgeIndex > maxPosition){
            maxPosition = edgeIndex;
            maxPositionIndex = i;
        }
//        NSLog(@"%d", *(edgePositionList + i));
    }
//    free(edgePositionList);
    NSInteger lastBlockBeginIndex = maxPosition;
    NSInteger lastDotLocation = [text rangeOfString:@"."
                                            options:NSBackwardsSearch
                                              range:NSMakeRange(lastBlockBeginIndex, caretLocation - lastBlockBeginIndex)].location;
    if(lastDotLocation != NSNotFound){
        NSString *innerText = [text substringWithRange:NSMakeRange(lastDotLocation + 1, caretLocation - lastDotLocation - 1)];
        if(![SVLuaCommonUtils isAlphbelts:innerText]){
            lastDotLocation = NSNotFound;
        }
    }
    NSInteger lastColonLocation = [text rangeOfString:@":"
                                              options:NSBackwardsSearch
                                                range:NSMakeRange(lastBlockBeginIndex, caretLocation - lastBlockBeginIndex)].location;
    if(lastColonLocation != NSNotFound){
        NSString *innerText = [text substringWithRange:NSMakeRange(lastColonLocation + 1, caretLocation - lastColonLocation - 1)];
        if(![SVLuaCommonUtils isAlphbelts:innerText]){
            lastColonLocation = NSNotFound;
        }
    }
    NSInteger lastInvokeLocation = NSNotFound;
    if(lastDotLocation != NSNotFound && lastColonLocation != NSNotFound){
        // find dot
        lastInvokeLocation = lastDotLocation > lastColonLocation ? lastDotLocation : lastColonLocation;
    }else if(lastColonLocation != NSNotFound){
        lastInvokeLocation = lastColonLocation;
    }else if(lastDotLocation != NSNotFound){
        lastInvokeLocation = lastDotLocation;
    }
    if(lastInvokeLocation != NSNotFound){
        *outPrefix = [text substringWithRange:NSMakeRange(lastInvokeLocation + 1, caretLocation - lastInvokeLocation - 1)];
        *outInvokePosition = lastInvokeLocation;
        if(lastInvokeLocation == lastDotLocation){
            // . grammar
            return kMethodInvokeViaDot;
        }else if(lastInvokeLocation == lastColonLocation){
            // : grammar
            return kMethodInvokeViaColon;
        }
    }
    if(maxPosition == 0){
        *outPrefix = [text substringWithRange:NSMakeRange(0, caretLocation)];
    }else{
        *outPrefix = [text substringWithRange:NSMakeRange(maxPosition + 1, caretLocation - maxPosition - 1)];
    }
    *outPrefix = [*outPrefix stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    *outInvokePosition = maxPosition;
    return kMethodInvokeViaNone;
}

- (void)updatePretypeSelectionList:(NSArray *)selectionList
{
    self.pretypeSelectionList = selectionList;
    [self.pretypeSelectionListTableView reloadData];
    [self setPretypeSelectionListTableViewHidden:selectionList.count == 0];
}

- (void)setPretypeSelectionListTableViewHidden:(BOOL)hidden
{
    self.pretypeSelectionListTableView.hidden = hidden;
    self.pretypeSelectionListTableViewShadowView.hidden = hidden;
}

- (void)setFunctionPositionListTableViewHidden:(BOOL)hidden
{
    self.functionPositionListTableView.hidden = hidden;
    self.functionPositionListTableViewShadowView.hidden = hidden;
    self.showFunctionIndexButton.style = hidden ? UIBarButtonItemStyleBordered : UIBarButtonItemStyleDone;
}

- (void)showTopToolbar:(BOOL)show
{
    self.showTopBarButton.style = show ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    [self setFunctionPositionListTableViewHidden:YES];
    BOOL repositionTextViewY = self.textView.contentOffset.y < self.topToolbar.frame.size.height;
    [UIView animateWithDuration:0.25f animations:^{
        self.textView.contentInset = UIEdgeInsetsMake(show ? self.topToolbar.frame.size.height : 0, 0, 0, 0);
        CGRect tmpRect = self.topToolbar.frame;
        tmpRect.origin.y = show ? 0 : -tmpRect.size.height;
        self.topToolbar.frame = tmpRect;
    } completion:^(BOOL finished) {
        if(repositionTextViewY){
            [self.textView scrollRangeToVisible:NSMakeRange(0, 0)];
        }
    }];
    if(show){
        [self.findReplaceView.findTextField becomeFirstResponder];
    }
}

- (BOOL)shouldTextViewBeResize
{
    return self.textView.isFirstResponder
    || self.findReplaceView.findTextField.isFirstResponder
    || self.findReplaceView.replaceTextField.isFirstResponder;
}

- (BOOL)shouldShowKeyboardToolsView
{
    return self.textView.isFirstResponder;
}

#pragma mark - events
- (void)consoleButtonTapped
{
    [[LogView sharedInstance] setHidden:NO];
}

- (void)showTopBarButtonTapped
{
    BOOL show = self.showTopBarButton.style == UIBarButtonItemStyleBordered;
    [self showTopToolbar:show];
}

- (void)showFunctionIndexButtonTapped
{
    [self.textView resignFirstResponder];
    if(self.functionPositionListTableView.hidden){
        [self showTopToolbar:NO];
        self.functionPositionList = [self.methodFinder cachedFunctionPositionList];
        [self setFunctionPositionListTableViewHidden:NO];
        [self.functionPositionListTableView reloadData];
    }else{
        [self setFunctionPositionListTableViewHidden:YES];
    }
}

- (void)viewAPIButtonTapped:(UIBarButtonItem *)barButtonItem
{
    
    if(!self.docViewController){
        DEAPIDocumentViewController *docVC = [[DEAPIDocumentViewController new] autorelease];
        [docVC setInsertTextBlock:^(NSString *text) {
//            [self.textView insertText:text];
//            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
//                [self.textView scrollRangeToVisible:self.textView.selectedRange];
//            }
        }];
        UINavigationController *tmpNC = [[[UINavigationController alloc] initWithRootViewController:docVC] autorelease];
        CGRect tmpRect = tmpNC.navigationBar.frame;
        tmpRect.size.width = 320;
        tmpNC.navigationBar.frame = tmpRect;
        self.docViewController = tmpNC;
    }
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if(self.docPopoverController && self.docPopoverController.popoverVisible){
            return;
        }
        UIPopoverController *popoverController = [[[UIPopoverController alloc] initWithContentViewController:self.docViewController] autorelease];
        popoverController.popoverContentSize = CGSizeMake(320, 480);
        [popoverController presentPopoverFromBarButtonItem:barButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        self.docPopoverController = popoverController;
    }else{
        [self presentModalViewController:self.docViewController animated:YES];
    }
}

- (void)runButtonTapped
{   
    NSString *script = self.textView.text;
    NSString *scriptName = self.scriptName;
    if(![SVLuaCommonUtils scriptIsMainScript:script]){
        scriptName = nil;
    }
    [self saveScript];
    if(self.runProjectBlock){
        self.runProjectBlock(scriptName);
    }
}

- (void)tabButtonTapped
{
    if(self.textView.selectedRange.length == 0){
        [self.textView insertText:@"\t"];
    }else{
        NSInteger caretLocation = self.textView.selectedRange.location;
        NSInteger lastNewLineLocation = [self.textView.text sv_find:@"\n" fromIndex:caretLocation reverse:YES];
        if(lastNewLineLocation == -1){
            lastNewLineLocation = 0;
        }
        NSInteger endNewLineLocation = [self.textView.text sv_find:@"\n" fromIndex:caretLocation + self.textView.selectedRange.length];
        if(endNewLineLocation == -1){
            endNewLineLocation = self.textView.text.length;
        }
        NSString *selectedLinesText = [self.textView.text sv_substringWithBeginIndex:lastNewLineLocation + 1 endIndex:endNewLineLocation];
        NSMutableString *resultString = [NSMutableString stringWithString:@"\t"];
        NSInteger beginIndex = 0;
        NSInteger endIndex = 0;
        while((beginIndex = [selectedLinesText sv_find:@"\n" fromIndex:endIndex]) != -1){
            [resultString appendFormat:@"%@\n\t", [selectedLinesText sv_substringWithBeginIndex:endIndex endIndex:beginIndex]];
            endIndex = beginIndex + 1;
        }
        if(endIndex != selectedLinesText.length){
            [resultString appendString:[selectedLinesText sv_substringWithBeginIndex:endIndex endIndex:selectedLinesText.length]];
        }
        NSString *leftString = [self.textView.text sv_substringWithBeginIndex:0 endIndex:lastNewLineLocation + 1];
        NSString *rightString = @"";
        if(endNewLineLocation != self.textView.text.length){
            rightString = [self.textView.text sv_substringWithBeginIndex:endNewLineLocation endIndex:self.textView.text.length];
        }
        self.textView.text = [NSString stringWithFormat:@"%@%@%@", leftString, resultString, rightString];
        self.textView.selectedRange = NSMakeRange(lastNewLineLocation + 1, 0);
        if([[[UIDevice currentDevice] systemVersion] compare:@"5.0"] == NSOrderedDescending){
            [self.textView insertText:@" "];
            [self.textView deleteBackward];
        }
        self.textView.selectedRange = NSMakeRange(lastNewLineLocation + 1, endNewLineLocation - lastNewLineLocation - 1);
    }
}

- (void)bracketButtonTapped
{
    NSRange lastRange = self.textView.selectedRange;
    [self.textView insertText:@"()"];
    self.textView.selectedRange = NSMakeRange(lastRange.location + 1, 0);
}

- (void)bigBracketButtonTapped
{
    NSRange lastRange = self.textView.selectedRange;
    [self.textView insertText:@"{}"];
    self.textView.selectedRange = NSMakeRange(lastRange.location + 1, 0);
}

- (void)quotesButtonTapped
{
    NSRange lastRange = self.textView.selectedRange;
    [self.textView insertText:@"\"\""];
    self.textView.selectedRange = NSMakeRange(lastRange.location + 1, 0);
}

- (void)semicolonButtonTapped
{
    [self.textView insertText:@";"];
}

- (void)assignButtonTapped
{
    [self.textView insertText:@"="];
}

- (void)negateButtonTapped
{
    [self.textView insertText:@" ~= "];
}

- (void)colonButtonTapped
{
    [self.textView insertText:@":"];
}

- (void)closeKeyboardButtonTapped
{
    [self.textView resignFirstResponder];
}

- (void)logButtonTapped
{
    NSRange lastRange = self.textView.selectedRange;
    [self.textView insertText:@"utils::log();"];
    self.textView.selectedRange = NSMakeRange(lastRange.location + 11, 0);
}

- (NSArray *)stringPositionListWithText:(NSString *)text matching:(NSString *)matching
{
    NSMutableArray *list = [NSMutableArray array];
    NSInteger beginIndex = 0;
    
    while((beginIndex = [text sv_find:matching fromIndex:beginIndex]) != -1){
        [list addObject:[DEStringPosition createWithPosition:beginIndex string:matching]];
        ++beginIndex;
    }
    
    return list;
}

- (void)pasteButtonTapped
{
    NSString *text = [[UIPasteboard generalPasteboard] string];
    NSArray *newLinePositoinList = [self stringPositionListWithText:text matching:@"\n"];
    NSArray *tabPositionList = [self stringPositionListWithText:text matching:@"\t"];
    NSMutableArray *allPositionList = [NSMutableArray arrayWithArray:newLinePositoinList];
    [allPositionList addObjectsFromArray:tabPositionList];
    [allPositionList sortUsingComparator:^NSComparisonResult(DEStringPosition *obj1, DEStringPosition *obj2) {
        return obj1.position > obj2.position ? NSOrderedDescending : NSOrderedAscending;
    }];
    NSInteger lastIndex = 0;
    for(NSInteger i = 0; i < allPositionList.count; ++i){
        DEStringPosition *sp = [allPositionList objectAtIndex:i];
        [self.textView insertText:[text sv_substringWithBeginIndex:lastIndex endIndex:sp.position]];
        [self.textView insertText:sp.string];
        lastIndex = sp.position + 1;
    }
    if(lastIndex != text.length){
        [self.textView insertText:[text substringFromIndex:lastIndex]];
    }
//    [self.textView insertText:[[UIPasteboard generalPasteboard] string]];
}

- (void)dotButtonTapped
{
    [self.textView insertText:@"."];
}

- (void)deleteLineButtonTapped
{
    NSUInteger caretLocation = self.textView.selectedRange.location;
    if(caretLocation == 0){
        return;
    }
    NSUInteger lastNewLineLocation = [self.textView.text rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, caretLocation)].location;
    if(lastNewLineLocation == NSNotFound){
        lastNewLineLocation = 0;
    }else{
        ++lastNewLineLocation;
        if(lastNewLineLocation == caretLocation){
            return;
        }
    }
    NSUInteger nextNewLineLocation = [self.textView.text rangeOfString:@"\n"
                                                               options:NSCaseInsensitiveSearch
                                                                 range:NSMakeRange(caretLocation, self.textView.text.length - caretLocation)].location;
    if(nextNewLineLocation == NSNotFound){
        nextNewLineLocation = self.textView.text.length;
    }
    nextNewLineLocation = caretLocation;
    NSString *blockText = [self.textView.text substringWithRange:NSMakeRange(lastNewLineLocation, caretLocation - lastNewLineLocation)];
    NSInteger numberOfTabs = [self numberOftabsForBlockText:blockText];
    NSString *text = self.textView.text;
    NSString *newText = [NSString stringWithFormat:@"%@%@", [text substringWithRange:NSMakeRange(0, lastNewLineLocation)],
                         [text substringWithRange:NSMakeRange(nextNewLineLocation, text.length - nextNewLineLocation)]];
    self.textView.text = newText;
    self.textView.selectedRange = NSMakeRange(lastNewLineLocation, 0);
    for(NSInteger i = 0; i < numberOfTabs; ++i){
        [self.textView insertText:@"\t"];
    }
    if([[[UIDevice currentDevice] systemVersion] compare:@"5.0"] == NSOrderedDescending){
        [self.textView insertText:@" "];
        [self.textView deleteBackward];
    }
}

- (void)gotoLineBeginButtonTapped
{
    NSUInteger caretLocation = self.textView.selectedRange.location;
    if(caretLocation == 0){
        return;
    }
    NSUInteger lastNewLineLocation = [self.textView.text rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, caretLocation - 1)].location;
    if(lastNewLineLocation == NSNotFound){
        lastNewLineLocation = 0;
    }else{
        ++lastNewLineLocation;
    }
    NSString *blockText = [self.textView.text substringWithRange:NSMakeRange(lastNewLineLocation, caretLocation - lastNewLineLocation)];
    NSInteger numberOfTabs = [self numberOftabsForBlockText:blockText];
    self.textView.selectedRange = NSMakeRange(lastNewLineLocation + numberOfTabs, 0);
}

- (void)gotoLineEndButtonTapped
{
    NSUInteger caretLocation = self.textView.selectedRange.location;
    NSUInteger nextNewLineLocation = [self.textView.text rangeOfString:@"\n"
                                                               options:NSCaseInsensitiveSearch
                                                                 range:NSMakeRange(caretLocation, self.textView.text.length - caretLocation)].location;
    if(nextNewLineLocation == NSNotFound){
        nextNewLineLocation = self.textView.text.length;
    }
    self.textView.selectedRange = NSMakeRange(nextNewLineLocation, 0);
}

- (void)keyboardWillShowNotification:(NSNotification *)n
{
    if(![self shouldTextViewBeResize]){
        return;
    }
    [self setFunctionPositionListTableViewHidden:YES];
    NSInteger animationCurve = [[n.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double animationDuration = [[n.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect endFrame = [[n.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? endFrame.size.width : endFrame.size.height;
    
    CGRect tmpRect;
    if([self shouldShowKeyboardToolsView]){
        self.keyboardToolsView.hidden = NO;
        tmpRect = self.keyboardToolsView.frame;
        tmpRect.origin.y = self.view.frame.size.height;
        self.keyboardToolsView.frame = tmpRect;
    }
    
    tmpRect = self.pretypeSelectionListTableView.frame;
    tmpRect.origin.y = self.view.frame.size.height - keyboardHeight - self.keyboardToolsView.bounds.size.height - tmpRect.size.height;
    if(tmpRect.origin.y < 0){
        tmpRect.origin.y = 0;
        tmpRect.size.height = self.view.frame.size.height - keyboardHeight - self.keyboardToolsView.bounds.size.height;
    }
    self.pretypeSelectionListTableView.frame = tmpRect;
    self.pretypeSelectionListTableViewShadowView.frame = self.pretypeSelectionListTableView.frame;
    
    [UIView animateWithDuration:animationDuration delay:0.0f options:animationCurve animations:^{
        CGRect tmpRect;
        if([self shouldShowKeyboardToolsView]){
            tmpRect = self.keyboardToolsView.frame;
            tmpRect.origin.y = self.view.frame.size.height - keyboardHeight - tmpRect.size.height;
            self.keyboardToolsView.frame = tmpRect;
        }
        
        CGFloat keyboardHeight = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? endFrame.size.width : endFrame.size.height;
        tmpRect = self.textView.frame;
        tmpRect.size.height = self.view.frame.size.height - keyboardHeight;
        if([self shouldShowKeyboardToolsView]){
            tmpRect.size.height -= self.keyboardToolsView.bounds.size.height;
        }
        self.textView.frame = tmpRect;
        
        tmpRect = self.pretypeSelectionListTableView.frame;
        tmpRect.origin.x = self.view.frame.size.width - tmpRect.size.width;
        self.pretypeSelectionListTableView.frame = tmpRect;
        
        self.pretypeSelectionListTableViewShadowView.frame = self.pretypeSelectionListTableView.frame;
    } completion:^(BOOL finished) {
    }];
}

- (void)keyboardWillHideNotification:(NSNotification *)n
{
    if(![self shouldTextViewBeResize]){
        return;
    }
    NSInteger animationCurve = [[n.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double animationDuration = [[n.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration delay:0.0f options:animationCurve animations:^{
        CGRect tmpRect;
        if([self shouldShowKeyboardToolsView]){
            tmpRect = self.keyboardToolsView.frame;
            tmpRect.origin.y = self.view.frame.size.height;
            self.keyboardToolsView.frame = tmpRect;
        }
        
        tmpRect = self.textView.frame;
        tmpRect.size.height = self.view.bounds.size.height;
        tmpRect.size.height -= self.bottomToolbar.frame.size.height;
        self.textView.frame = tmpRect;
        
        tmpRect = self.pretypeSelectionListTableView.frame;
        tmpRect.origin.x = self.view.frame.size.width;
        self.pretypeSelectionListTableView.frame = tmpRect;
        
        self.pretypeSelectionListTableViewShadowView.frame = self.pretypeSelectionListTableView.frame;
    } completion:^(BOOL finished) {
        [self setPretypeSelectionListTableViewHidden:YES];
    }];
}

- (void)keyboardDidHideNotification:(NSNotification *)n
{
    self.keyboardToolsView.hidden = YES;
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)n
{
    [self saveScript];
    if(self.stopRunningBlock){
        self.stopRunningBlock();
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)n
{
    
}


#pragma mark - UITableViewDelegate & dataSource
- (NSString *)removeParamsForMethod:(NSString *)method outLeftBracketPosition:(NSInteger *)outLeftBracketPosition rightBracketExists:(BOOL)rightBracketExists
{
    NSInteger beginIndex = [method rangeOfString:@"("].location;
    NSInteger endIndex = [method rangeOfString:@")"].location;
    if(beginIndex != NSNotFound && endIndex != NSNotFound){
        if(rightBracketExists){
            *outLeftBracketPosition = beginIndex;
            return [method substringWithRange:NSMakeRange(0, beginIndex)];
        }else{
            ++beginIndex;
            NSString *params = [method substringWithRange:NSMakeRange(beginIndex, endIndex - beginIndex)];
            params = [params stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            *outLeftBracketPosition = beginIndex;
            NSMutableString *newParams = [NSMutableString string];
            if(params.length == 0){
                *outLeftBracketPosition = endIndex + 1;
            }else{
                NSInteger numberOfParams = [params componentsSeparatedByString:@","].count + 1;
                for(NSInteger i = 0; i < numberOfParams - 2; ++i){
                    [newParams appendString:@", "];
                }
            }
            return [NSString stringWithFormat:@"%@%@)", [method substringWithRange:NSMakeRange(0, beginIndex)], newParams];
        }
    }else if([method hasPrefix:@"require"] || [method hasPrefix:@"return"]){
        *outLeftBracketPosition = method.length - 1;
    }else{
        *outLeftBracketPosition = method.length;
    }
    
    return method;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tableView == self.pretypeSelectionListTableView){
        NSString *text = self.textView.text;
        NSString *prefix = nil;
        DEPretype *tmpPretype = [self.pretypeSelectionList objectAtIndex:indexPath.row];
        
        if(self.currentInvokePosition == 0){
            prefix = @"";
        }else{
            prefix = [text substringToIndex:self.currentInvokePosition + 1];
        }
        BOOL rightBracketExists = NO;
        NSUInteger rightBracketLocation = [text rangeOfString:@"(" options:NSCaseInsensitiveSearch
                                                        range:NSMakeRange(self.currentInvokeCaretLocation, text.length - self.currentInvokeCaretLocation)].location;
        if(rightBracketLocation != NSNotFound){
            NSString *innerText = [text substringWithRange:NSMakeRange(self.currentInvokeCaretLocation, rightBracketLocation - self.currentInvokeCaretLocation)];
            if([SVLuaCommonUtils isAlphbelts:[innerText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]){
                rightBracketExists = YES;
            }
        }
        NSInteger leftBracketPosition = 0;
        NSString *replaceMethodName = nil;
        BOOL originalParams = NO;
        if(!originalParams){
            NSInteger leftEdge = [text sv_find:@"\n" fromIndex:self.currentInvokePosition reverse:YES];
            if(leftEdge == -1){
                leftEdge = 0;
            }else{
                ++leftEdge;
            }
            NSInteger lastWhitespace = [text sv_find:@" " fromIndex:self.currentInvokePosition reverse:YES];
            if(leftEdge < lastWhitespace){
                NSString *innerText = [text sv_substringWithBeginIndex:leftEdge endIndex:lastWhitespace];
                innerText = [innerText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if([innerText isEqualToString:@"function"]){
                    originalParams = YES;
                }
            }
        }
        if(originalParams){
            replaceMethodName = tmpPretype.text;
            leftBracketPosition = replaceMethodName.length;
        }else{
            replaceMethodName = [self removeParamsForMethod:tmpPretype.text
                                     outLeftBracketPosition:&leftBracketPosition
                                         rightBracketExists:rightBracketExists];
        }
        NSString *suffix = [text substringFromIndex:self.currentInvokeCaretLocation];
        self.currentInvokeCaretLocation = prefix.length + replaceMethodName.length;
        if([self.textView respondsToSelector:@selector(setTextDidResetBlock:)]){
            [self setPretypeSelectionListTableViewHidden:YES];
        }
        self.textView.text = [NSString stringWithFormat:@"%@%@%@", prefix, replaceMethodName, suffix];
        self.textView.selectedRange = NSMakeRange(prefix.length + leftBracketPosition, 0);
        if([[[UIDevice currentDevice] systemVersion] compare:@"5.0"] == NSOrderedDescending){
            [self.textView insertText:@" "];
            [self.textView deleteBackward];
        }
        if(![self.textView respondsToSelector:@selector(setTextDidResetBlock:)]){
            [self setPretypeSelectionListTableViewHidden:YES];
        }
    }else if(tableView == self.functionPositionListTableView){
        DEFunctionPosition *tmpFP = [self.functionPositionList objectAtIndex:indexPath.row];
        self.textView.selectedRange = NSMakeRange(tmpFP.location, tmpFP.functionName.length);
        [self setFunctionPositionListTableViewHidden:YES];
        [self.textView becomeFirstResponder];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.pretypeSelectionListTableView){
        return self.pretypeSelectionList.count;
    }else if(tableView == self.functionPositionListTableView){
        return self.functionPositionList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.pretypeSelectionListTableView){
        static NSString *identifier = @"__id";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            cell.textLabel.numberOfLines = 2;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor blackColor];
            
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.textColor = [UIColor blackColor];
            
            cell.backgroundView = [[UIView new] autorelease];
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView.backgroundColor = [UIColor whiteColor];
            cell.backgroundView.alpha = 0.50f;
        }
        DEPretype *tmpPretype = [self.pretypeSelectionList objectAtIndex:indexPath.row];
        cell.textLabel.text = tmpPretype.text;
        cell.detailTextLabel.text = tmpPretype.additionalText;
        
        return cell;
    }else if(tableView == self.functionPositionListTableView){
        static NSString *identifier = @"__id";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            cell.textLabel.numberOfLines = 0;
        }
        DEFunctionPosition *fp = [self.functionPositionList objectAtIndex:indexPath.row];
        cell.textLabel.text = [fp.functionName substringFromIndex:9];
        
        return cell;
    }
    return nil;
}

#pragma mark - UITextViewDelegate
- (NSInteger)lineNumber
{
    if(self.textView.text.length == 0){
        return 1;
    }
    NSString *subText = [self.textView.text substringToIndex:self.textView.selectedRange.location];
    NSInteger beginIndex = 0;
    NSInteger endIndex = 0;
    NSInteger count = 1;
    while((beginIndex = [subText sv_find:@"\n" fromIndex:endIndex]) != -1){
        endIndex = beginIndex + 1;
        ++count;
    }
    
    return count;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self saveScript];
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if(self.pretypeSelectionList.count != 0){
        if(self.blockPretypeAnalyse){
            return;
        }
        [self setPretypeSelectionListTableViewHidden:self.textView.selectedRange.location != self.currentInvokeCaretLocation];
    }
    self.lineNumberLabel.title = [NSString stringWithFormat:@"%d", [self lineNumber]];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        NSLog(@"%@", self.lineNumberLabel.title);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    self.textViewLastAction = range.length == 0 ? kTextViewActionInsert : kTextViewActionRemove;
    return YES;
}

- (NSString *)findBlockTextWithCaretLocation:(NSUInteger)caretLocation text:(NSString *)text
{
    NSUInteger lastNewLineLocation = [text rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, caretLocation - 1)].location;
    if(lastNewLineLocation == NSNotFound){
        lastNewLineLocation = 0;
    }else{
        ++lastNewLineLocation;
    }
    NSString *blockText = [text substringWithRange:NSMakeRange(lastNewLineLocation, caretLocation - lastNewLineLocation)];
    return blockText;
}

- (NSString *)blockPrefixForBlockText:(NSString *)blockText
{
    NSRange range = [blockText rangeOfString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, blockText.length)];
    if(range.location != NSNotFound){
        return [[blockText substringToIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    blockText = [blockText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    static NSArray *completeBlockTextArray = nil;
    if(completeBlockTextArray == nil){
        completeBlockTextArray = @[@"do", @"else", @"repeat"];
        [completeBlockTextArray retain];
    }
    if([completeBlockTextArray indexOfObject:blockText] != NSNotFound){
        return blockText;
    }
    return nil;
}

- (NSInteger)numberOftabsForBlockText:(NSString *)blockText
{
    NSInteger count = 0;
    for(NSInteger i = 0; i < blockText.length; ++i){
        if([blockText characterAtIndex:i] == '\t'){
            ++count;
        }else{
            break;
        }
    }
    return count;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self.textInputCatcher mark];
    [self.highlightInputCatcher mark];
    [self.saveInputCatcher mark];
//    [self.textView resetAttributedText];
    
    NSUInteger caretLocation = textView.selectedRange.location;
    NSString *text = textView.text;
    if(self.textViewLastAction == kTextViewActionInsert && caretLocation != 0){
        unsigned char lastChar = [text characterAtIndex:caretLocation - 1];
        if(lastChar == '\n'){
            NSString *blockText = [self findBlockTextWithCaretLocation:caretLocation text:text];
            NSString *blockPrefix = [self blockPrefixForBlockText:blockText];
            NSArray *blockPrefixArray = nil;
            if(blockPrefixArray == nil){
                blockPrefixArray = @[@"function", @"if", @"while", @"for", @"else", @"elseif", @"repeat", @"do"];
                [blockPrefixArray retain];
            }
            NSInteger numberOfTabs = [self numberOftabsForBlockText:blockText];
            if([blockPrefixArray indexOfObject:blockPrefix] != NSNotFound){
                ++numberOfTabs;
            }
            for(NSInteger i = 0; i < numberOfTabs; ++i){
                [self.textView insertText:@"\t"];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    [scrollView setNeedsDisplay];
}

#pragma mark - QRFindReplaceViewDelegate
- (void)findText:(NSString *)text findReplaceView:(QRFindReplaceView *)view
{
    if(!self.stringPositionFinder){
        self.stringPositionFinder = [[StringPositionFinder new] autorelease];
    }
    NSArray *positionList = [self.stringPositionFinder stringPositionListWithString:self.textView.text matching:text isCaseSensitive:YES];
    view.matchingCountLabel.text = [NSString stringWithFormat:@"%d", positionList.count];
    self.lastReplacedText = nil;
//    if(positionList.count != 0){
//        StringPosition *sp = [self.stringPositionFinder beginPosition];
//        self.textView.selectedRange = NSMakeRange(sp.position, sp.string.length);
//        [self.textView becomeFirstResponder];
//    }
}

- (void)replaceTextWithFindText:(NSString *)findText replaceText:(NSString *)replaceText range:(NSRange)range
{
    BOOL isCaseSensitive = YES;
    if(findText.length == 0){
        findText = @"";
    }
    if(replaceText.length == 0){
        replaceText = @"";
    }
    self.textView.text = [self.textView.text stringByReplacingOccurrencesOfString:findText
                                                                       withString:replaceText
                                                                          options:isCaseSensitive ? NSLiteralSearch : NSCaseInsensitiveSearch
                                                                            range:range];
}

- (void)QRFindReplaceViewFindTextFieldDidBeginEdit:(QRFindReplaceView *)view
{
    if(view.findTextField.text.length != 0){
        [self findText:view.findTextField.text findReplaceView:view];
    }
}

- (void)QRFindReplaceView:(QRFindReplaceView *)view findTextFieldTextDidChange:(NSString *)text
{
    if(!self.findTextInputCatcher){
        self.findTextInputCatcher = [[[DETextInputCatcher alloc] initWithWaitingInterval:0.50f] autorelease];
        [self.findTextInputCatcher start:^{
            [self findText:view.findTextField.text findReplaceView:view];
        }];
    }
    [self.findTextInputCatcher mark];
}

- (void)QRFindReplaceViewFindTextFieldDidEndEdit:(QRFindReplaceView *)view
{
    if(view.findTextField.text.length == 0){
        [self showTopToolbar:NO];
    }
}

- (void)QRFindReplaceViewReplaceButtonDidTapped:(QRFindReplaceView *)view
{
    NSString *srcText = view.findTextField.text;
    if(self.lastReplacedText != nil){
        srcText = self.lastReplacedText;
    }
    if(self.stringPositionFinder.currentPosition){
        [self replaceTextWithFindText:srcText
                          replaceText:view.replaceTextField.text
                                range:NSMakeRange(self.stringPositionFinder.currentPosition.position, srcText.length)];
        self.lastReplacedText = view.replaceTextField.text == nil ? @"" : view.replaceTextField.text;
        view.matchingCountLabel.text = @"";
    }
}

- (void)QRFindReplaceViewReplaceAllButtonDidTapped:(QRFindReplaceView *)view
{
    [self replaceTextWithFindText:view.findTextField.text replaceText:view.replaceTextField.text range:NSMakeRange(0, self.textView.text.length)];
    view.matchingCountLabel.text = @"";
    self.lastReplacedText = nil;
    [self.stringPositionFinder reset];
}

- (void)QRFindReplaceViewPreviousButtonDidTapped:(QRFindReplaceView *)view
{
    DEStringPosition *sp = [self.stringPositionFinder previousPosition];
    if(sp){
        self.textView.selectedRange = NSMakeRange(sp.position, sp.string.length);
        [self.textView becomeFirstResponder];
        [self.textView scrollRangeToVisible:self.textView.selectedRange];
        view.matchingCountLabel.text = [NSString stringWithFormat:@"%d/%d",
                                        [self.stringPositionFinder currentPositionIndex] + 1, [self.stringPositionFinder numberOfPositions]];
    }
}

- (void)QRFindReplaceViewNextButtonDidTapped:(QRFindReplaceView *)view
{
    DEStringPosition *sp = [self.stringPositionFinder nextPosition];
    if(sp){
        self.textView.selectedRange = NSMakeRange(sp.position, sp.string.length);
        [self.textView becomeFirstResponder];
        [self.textView scrollRangeToVisible:self.textView.selectedRange];
        view.matchingCountLabel.text = [NSString stringWithFormat:@"%d/%d",
                                        [self.stringPositionFinder currentPositionIndex] + 1, [self.stringPositionFinder numberOfPositions]];
    }
}

@end
