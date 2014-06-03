//
//  BaseViewController.m
//  VOA
//
//  Created by yangzexin on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DEBaseViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProviderPool.h"

@interface DEBaseViewController ()

@property(nonatomic, retain)UILabel *titleLabel;
@property(nonatomic, copy)NSString *customTitle;
@property(nonatomic, retain)SVProviderPool *providerPool;

@end


@implementation DEBaseViewController

- (void)dealloc
{
    self.customTitle = nil;
    self.titleLabel = nil;
    self.providerPool = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    self.title = NSLocalizedString(@"Back", nil);
    self.customTitle = @"Untitled";
    
    self.providerPool = [[SVProviderPool new] autorelease];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)loadView
{
    [super loadView];
    
    BOOL ios7 = [UIDevice currentDevice].systemVersion.floatValue >= 7.0f;
    
    self.titleLabel = [UIFactory label];
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel.textColor = ios7 ? [UIColor blackColor] : [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    self.titleLabel.text = _customTitle;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    if (!ios7) {
        self.titleLabel.layer.shadowRadius = 0.5f;
        self.titleLabel.layer.shadowOpacity = 1.0f;
        self.titleLabel.layer.shadowOffset = CGSizeMake(0, -0.5f);
        self.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    }
    self.titleLabel.frame = CGRectMake(0, 0, [_customTitle sizeWithFont:self.titleLabel.font].width,
                                       self.titleLabel.font.lineHeight);
    self.navigationItem.titleView = self.titleLabel;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    }
}

- (void)setCustomTitle:(NSString *)customTitle
{
    if(_customTitle != customTitle){
        [_customTitle release];
    }
    _customTitle = [customTitle copy];
    if(self.titleLabel){
        self.titleLabel.text = _customTitle;
        self.titleLabel.frame = CGRectMake(0, 0,
                                           [_customTitle sizeWithFont:self.titleLabel.font].width,
                                           self.titleLabel.font.lineHeight);
    }
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:NSLocalizedString(@"Back", nil)];
    self.customTitle = title;
}

- (void)addProviderToPool:(id<SVProviderPoolable>)provider
{
    [_providerPool tryToReleaseProvider];
    [_providerPool addProvider:provider];
}

- (UIView *)customTitleView
{
    return self.titleLabel;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return YES;
    }
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return YES;
    }
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    if([[UIDevice currentDevice].systemVersion compare:@"5.0"] == NSOrderedAscending){
        [super presentModalViewController:viewControllerToPresent animated:flag];
    }else{
        [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    if([[UIDevice currentDevice].systemVersion compare:@"5.0"] == NSOrderedAscending){
        [super dismissModalViewControllerAnimated:flag];
    }else{
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}

@end
