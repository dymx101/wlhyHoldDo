//
//  WlhyStrengthPrescriptionViewController.h
//  wlhybdc
//
//  Created by ios on 13-8-2.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WlhyStrengthPrescriptionViewController : UITableViewController

@property(strong, nonatomic) NSString *barDecode;
@property(strong, nonatomic) NSString *prescriptionId;
@property(strong, nonatomic) NSNumber *temporaryTrainID;
@property(assign, nonatomic) BOOL isBackFromTrainSelection;

@end
