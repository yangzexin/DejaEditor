//
//  QRFindReplaceView.m
//  Quartz2d_Learning
//
//  Created by yangzexin on 13-2-26.
//
//

#import "QRFindReplaceView.h"

@interface QRFindReplaceView () <UITextFieldDelegate>

@end

@implementation QRFindReplaceView

- (void)dealloc
{
    [_matchingCountLabel release];
    [_findTextField release];
    [_selectMatchingSegmentedControl release];
    [_replaceTextField release];
    [_replaceSegmentedControl release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    CGFloat labelWidth = 30.0f;
    CGFloat segmentedControlWidth = 60;
    CGFloat spacing = 2.0f;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        segmentedControlWidth = 100;
        labelWidth = 50.0f;
        spacing = 5.0f;
    }
    CGFloat textFieldHeight = 35.0f;
    
    _matchingCountLabel = [UILabel new];
    _matchingCountLabel.adjustsFontSizeToFitWidth = YES;
    self.matchingCountLabel.backgroundColor = [UIColor clearColor];
    self.matchingCountLabel.font = [UIFont systemFontOfSize:14.0f];
    self.matchingCountLabel.frame = CGRectMake(spacing, 0, labelWidth, frame.size.height);
    self.matchingCountLabel.textAlignment = UITextAlignmentCenter;
    [self addSubview:self.matchingCountLabel];
    
    _findTextField = [[self createTextField] retain];
    self.findTextField.frame = CGRectMake(self.matchingCountLabel.frame.size.width + self.matchingCountLabel.frame.origin.x + spacing,
                                          (frame.size.height - textFieldHeight) / 2,
                                          (frame.size.width - labelWidth - 2 * segmentedControlWidth - 6 * spacing) / 2,
                                          textFieldHeight);
    _selectMatchingSegmentedControl = [[self createSegmentedControlWithFirstTitle:@"<-" secondTitle:@"->"] retain];
    self.selectMatchingSegmentedControl.frame = CGRectMake(self.findTextField.frame.origin.x + self.findTextField.frame.size.width + spacing,
                                                           self.findTextField.frame.origin.y,
                                                           segmentedControlWidth,
                                                           self.findTextField.frame.size.height);
    _replaceTextField = [[self createTextField] retain];
    self.replaceTextField.frame = CGRectMake(self.selectMatchingSegmentedControl.frame.origin.x + self.selectMatchingSegmentedControl.frame.size.width + spacing,
                                             self.findTextField.frame.origin.y,
                                             self.findTextField.frame.size.width,
                                             self.findTextField.frame.size.height);
    _replaceSegmentedControl = [[self createSegmentedControlWithFirstTitle:@"R" secondTitle:@"RA"] retain];
    self.replaceSegmentedControl.frame = CGRectMake(self.replaceTextField.frame.origin.x + self.replaceTextField.frame.size.width + spacing,
                                                    self.selectMatchingSegmentedControl.frame.origin.y,
                                                    segmentedControlWidth,
                                                    self.selectMatchingSegmentedControl.frame.size.height);
    
    return self;
}

- (UITextField *)createTextField
{
    UITextField *textField = [[UITextField new] autorelease];
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    [textField addTarget:self action:@selector(textDidEndOnExit) forControlEvents:UIControlEventEditingDidEndOnExit];
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    textField.font = [UIFont systemFontOfSize:14.0f];
    [textField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:textField];
    
    return textField;
}

- (void)textDidEndOnExit
{
}

- (void)textFieldTextDidChange:(UITextField *)textField
{
    if(textField == self.findTextField){
        if([self.delegate respondsToSelector:@selector(QRFindReplaceView:findTextFieldTextDidChange:)]){
            [self.delegate QRFindReplaceView:self findTextFieldTextDidChange:textField.text];
        }
    }
}

- (UISegmentedControl *)createSegmentedControlWithFirstTitle:(NSString *)firstTitle secondTitle:(NSString *)secondTitle
{
    UISegmentedControl *segControl = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:firstTitle, secondTitle, nil]] autorelease];
    segControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    segControl.momentary = YES;
    [segControl addTarget:self action:@selector(segControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:segControl];
    
    return segControl;
}

#pragma mark - events
- (void)segControlValueChanged:(UISegmentedControl *)segControl
{
    if(segControl == self.selectMatchingSegmentedControl){
        if(self.selectMatchingSegmentedControl.selectedSegmentIndex == 0){
            if([self.delegate respondsToSelector:@selector(QRFindReplaceViewPreviousButtonDidTapped:)]){
                [self.delegate QRFindReplaceViewPreviousButtonDidTapped:self];
            }
        }else if(self.selectMatchingSegmentedControl.selectedSegmentIndex == 1){
            if([self.delegate respondsToSelector:@selector(QRFindReplaceViewNextButtonDidTapped:)]){
                [self.delegate QRFindReplaceViewNextButtonDidTapped:self];
            }
        }
    }else if(segControl == self.replaceSegmentedControl){
        if(self.replaceSegmentedControl.selectedSegmentIndex == 0){
            if([self.delegate respondsToSelector:@selector(QRFindReplaceViewReplaceButtonDidTapped:)]){
                [self.delegate QRFindReplaceViewReplaceButtonDidTapped:self];
            }
        }else if(self.replaceSegmentedControl.selectedSegmentIndex == 1){
            if([self.delegate respondsToSelector:@selector(QRFindReplaceViewReplaceAllButtonDidTapped:)]){
                [self.delegate QRFindReplaceViewReplaceAllButtonDidTapped:self];
            }
        }
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == self.findTextField){
        if([self.delegate respondsToSelector:@selector(QRFindReplaceViewFindTextFieldDidBeginEdit:)]){
            [self.delegate QRFindReplaceViewFindTextFieldDidBeginEdit:self];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.findTextField){
        if([self.delegate respondsToSelector:@selector(QRFindReplaceViewFindTextFieldDidEndEdit:)]){
            [self.delegate QRFindReplaceViewFindTextFieldDidEndEdit:self];
        }
    }
}

@end
