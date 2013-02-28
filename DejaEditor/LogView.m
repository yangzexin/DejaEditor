//
//  LogView.m
//  GoogleMapLocation
//
//  Created by gewara on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LogView.h"
#import "SVCommonUtils.h"

@interface LogView ()

@property(nonatomic, retain)UIView *containerView;
@property(nonatomic, retain)UITextView *textView;

@property(nonatomic, assign)BOOL lock;

@end

@implementation LogView

@synthesize textView = _textView;

@synthesize lock = _lock;

+ (LogView *)sharedInstance
{
    static LogView *instance = nil;
    @synchronized(instance){
        if(instance == nil){
            instance = [[LogView alloc] init];
        }
    }
    return instance;
}

- (id)init
{
    self = [super init];
    self.lock = NO;
    
    UIView *containerView = [[UIView new] autorelease];
    containerView.userInteractionEnabled = YES;
    [[[[UIApplication sharedApplication] windows] lastObject] addSubview:containerView];
    containerView.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20);
    self.containerView = containerView;
    
    UIView *bgView = [[[UIView alloc] initWithFrame:containerView.bounds] autorelease];
    [containerView addSubview:bgView];
    bgView.userInteractionEnabled = NO;
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.52f;
    
    self.textView = [[UITextView new] autorelease];
    [containerView addSubview:self.textView];
    self.textView.frame = self.containerView.bounds;
    self.textView.font = [UIFont systemFontOfSize:14.0f];
    self.textView.editable = NO;
    self.textView.backgroundColor = [UIColor clearColor];  
    self.textView.textColor = [UIColor whiteColor];
    self.textView.userInteractionEnabled = YES;
    self.textView.text = [self lastLog];
    [self.textView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewTapped)] autorelease]];
    return self;
}

- (void)dealloc
{
    [_textView release];
    [super dealloc];
}

- (void)saveToLastLog:(NSString *)log
{
    NSString *filePath = [[SVCommonUtils tmpPath] stringByAppendingPathComponent:@"log.txt"];
    [log writeToFile:filePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)lastLog
{
    NSString *filePath = [[SVCommonUtils tmpPath] stringByAppendingPathComponent:@"log.txt"];
    return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

- (void)log:(NSString *)log
{
    NSLog(@"%@", log);
    [self saveToLastLog:log];
    if(self.textView.text.length == 0){
        self.textView.text = [NSString stringWithFormat:@"%@\n", log];
    }else{
        self.textView.text = [NSString stringWithFormat:@"%@%@\n", self.textView.text, log];
    }
    if(!self.lock){
        [self.textView scrollRectToVisible:CGRectMake(0, 
                                                      self.textView.contentSize.height - self.textView.frame.size.height, 
                                                      self.textView.frame.size.width, 
                                                      self.textView.frame.size.height) 
                                  animated:YES];
    }
}

- (void)clear
{
    self.textView.text = @"";
}

- (void)setHidden:(BOOL)hidden
{
    self.containerView.hidden = hidden;
    self.textView.hidden = hidden;
}

- (BOOL)hidden
{
    return self.containerView.hidden;
}

#pragma mark - events
- (void)textViewTapped
{
    [self setHidden:![self hidden]];
}

@end
