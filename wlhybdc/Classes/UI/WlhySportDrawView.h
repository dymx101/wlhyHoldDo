//
//  WlhySportDrawView.h
//  wlhybdc
//
//  Created by linglong meng on 12-10-23.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WlhySportDrawView : UIView

@property(nonatomic,assign)CGFloat pad;
@property(nonatomic,assign)CGPoint origin;
@property(nonatomic,assign)CGFloat x_scale;//x坐标长度
@property(nonatomic,assign)CGFloat y_scale;//y坐标长度
@property(nonatomic,assign)CGFloat x_unit; //一个x刻度的度量值
@property(nonatomic,assign)CGFloat y_unit; //一个y刻度的度量值
@property(nonatomic,assign)CGFloat timeSpan; // 时间单位min
@property(nonatomic,assign) NSUInteger currentStep;

@property(nonatomic,strong) NSArray* dataSource;
@property(nonatomic,assign)BOOL needRedraw;
@property(nonatomic,assign)NSTimeInterval continueTime;

-(void)start;
-(void)stop;
-(void)resume;
-(void)pause;

@end
