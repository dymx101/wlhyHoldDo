//
//  WlhyTrainInfoViewController.h
//  wlhybdc
//
//  Created by ios on 13-7-18.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RechargeVCPurposeRecharge = 0,
    RechargeVCPurposeChangeTrain = 1,
    RechargeVCPurposeSportGuide = 2,
}RechargeVCPurpose;

@interface WlhyTrainInfoViewController : UITableViewController

@property(strong, nonatomic) NSNumber *trainID;
@property(assign, nonatomic) RechargeVCPurpose rechargeVCPurpose;

@end
