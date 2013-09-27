//
//  WlhyTyjPrescriptionViewController.h
//  wlhybdc
//
//  Created by Hello on 13-9-9.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WlhyTyjPrescriptionViewController : UITableViewController

@property(strong, nonatomic) NSString *barDecode;
@property(strong, nonatomic) NSString *prescriptionId;
@property(strong, nonatomic) NSNumber *temporaryTrainID;
@property(assign, nonatomic) BOOL isBackFromTrainSelection;

@end
