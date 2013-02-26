//
//  QRFindReplaceView.h
//  Quartz2d_Learning
//
//  Created by yangzexin on 13-2-26.
//
//

#import <Foundation/Foundation.h>

@class QRFindReplaceView;

@protocol QRFindReplaceViewDelegate <NSObject>

@optional
- (void)QRFindReplaceViewFindTextFieldDidBeginEdit:(QRFindReplaceView *)view;
- (void)QRFindReplaceView:(QRFindReplaceView *)view findTextFieldTextDidChange:(NSString *)text;
- (void)QRFindReplaceViewFindTextFieldDidEndEdit:(QRFindReplaceView *)view;
- (void)QRFindReplaceViewReplaceButtonDidTapped:(QRFindReplaceView *)view;
- (void)QRFindReplaceViewReplaceAllButtonDidTapped:(QRFindReplaceView *)view;
- (void)QRFindReplaceViewPreviousButtonDidTapped:(QRFindReplaceView *)view;
- (void)QRFindReplaceViewNextButtonDidTapped:(QRFindReplaceView *)view;

@end

@interface QRFindReplaceView : UIView

@property(nonatomic, assign)id<QRFindReplaceViewDelegate> delegate;
@property(nonatomic, readonly)UILabel *matchingCountLabel;
@property(nonatomic, readonly)UITextField *findTextField;
@property(nonatomic, readonly)UISegmentedControl *selectMatchingSegmentedControl;
@property(nonatomic, readonly)UITextField *replaceTextField;
@property(nonatomic, readonly)UISegmentedControl *replaceSegmentedControl;

@end
