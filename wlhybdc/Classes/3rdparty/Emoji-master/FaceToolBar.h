//
//  FaceToolBar.h
//  TestKeyboard
//
//  Created by wangjianle on 13-2-26.
//  Copyright (c) 2013年 wangjianle. All rights reserved.
//
#define Time  0.25
//#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define  keyboardHeight 216
#define  toolBarHeight 45
#define  choiceBarHeight 35
#define  facialViewWidth 300
#define facialViewHeight 170
#define  buttonWh 34


#import <UIKit/UIKit.h>
#import "FacialView.h"
#import "UIExpandingTextView.h"

@protocol FaceToolBarDelegate <NSObject>

-(void)sendTextAction:(NSString *)inputText;

@end

//-------------------------------------------------------------------------

@interface FaceToolBar : UIToolbar <facialViewDelegate,UIExpandingTextViewDelegate,UIScrollViewDelegate>

@property(nonatomic,strong)UIView *theSuperView;
@property (weak) NSObject<FaceToolBarDelegate> *delegate;


- (void)dismissKeyBoard;
- (id)initWithFrame:(CGRect)frame superView:(UIView *)superView;


@end
