//
//  WlhyMuitableSelectView.h
//  wlhybdc
//
//  Created by linglong meng on 12-11-7.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WlhyMuitableSelectView : UIView

@property(nonatomic,strong)NSString* jsonArray;

@property(nonatomic,strong)NSMutableArray* selectedIndexs;

// split by ,
@property(nonatomic,readonly) NSString* selectedIndexString;

@property (nonatomic) NSInteger columnCount;
@property (nonatomic) CGFloat   padding;
@property (nonatomic) CGFloat   spacing;
@property(nonatomic)  NSInteger  maxSelected;

@end
