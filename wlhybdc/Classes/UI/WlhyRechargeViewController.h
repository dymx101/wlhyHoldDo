//
//  WlhyRechargeViewController.h
//  wlhybdc
//
//  Created by linglong meng on 12-11-1.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RechargeVCPurposeRecharge = 0,
    RechargeVCPurposeChangeTrain = 1,
    RechargeVCPurposeSportGuide = 2,
}RechargeVCPurpose;

@interface WlhyRechargeViewController : UITableViewController

@property(assign, nonatomic) RechargeVCPurpose rechargeVCPurpose;

@end
