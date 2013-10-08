//
//  DatePickerView.h
//  wlhybdc
//
//  Created by Hello on 13-10-8.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DatePickerView;

@protocol DatePickerViewDelegate <NSObject>

- (void)didCancelDatePickerView:(DatePickerView *)kPickerView;
- (void)didEnsureDatePickerView:(DatePickerView *)kPickerView WithstartDate:(NSString *)kStartDate endDate:(NSString *)kEndDate;

@end


@interface DatePickerView : UIView

@property(assign, nonatomic) id <DatePickerViewDelegate> delegate;

@end
