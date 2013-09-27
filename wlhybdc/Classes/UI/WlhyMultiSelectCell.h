//
//  WlhyMultiSelectCell.h
//  wlhybdc
//
//  Created by linglong meng on 12-11-6.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WlhyMultiSelectCell : UITableViewCell
@property(nonatomic,strong)NSString* jsonArray;

@property(nonatomic,strong)NSArray* selectedIndexs;

@end
