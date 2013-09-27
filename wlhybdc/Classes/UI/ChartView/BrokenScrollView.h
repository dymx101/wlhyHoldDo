//
//  CurveScrollView.h
//  ScrollViewTest
//
//  Created by miracles3 on 13-4-22.
//  Copyright (c) 2013年 miracles3. All rights reserved.
//

#import <UIKit/UIKit.h>


#define X_LABEL_HEIGHT 15       //显示x坐标文字的区域的高度


@interface BrokenScrollView : UIView


@property(assign, nonatomic) float max;
@property(assign, nonatomic) float min;


- (id)initWithFrame:(CGRect)frame dataArray:(NSArray *)kDataArray;


@end
