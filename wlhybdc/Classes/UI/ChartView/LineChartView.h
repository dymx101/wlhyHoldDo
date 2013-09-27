//
//  LineChartView.h
//  wlhybdc
//
//  Created by ios on 13-7-29.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LineChartView : UIView


@property(retain, nonatomic) NSArray *dataSource;


- (void)movePointerWithTime:(float)time;

@end
