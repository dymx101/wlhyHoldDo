//
//  WlhySportTotalCell.h
//  wlhybdc
//
//  Created by linglong meng on 12-10-31.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    SportButtonStateStart,
    SportButtonStatePause,
    SportButtonStateStop
}SportButtonState;


@interface WlhySportTotalCell : UITableViewCell


@property(nonatomic,assign) SportButtonState sportButtonState;

@property (strong, nonatomic) IBOutlet UILabel *totalTime;
@property (strong, nonatomic) IBOutlet UILabel *totalDistance;
@property (strong, nonatomic) IBOutlet UILabel *totalKal;

@property (strong, nonatomic) IBOutlet UILabel *durationDistance;
@property (strong, nonatomic) IBOutlet UILabel *durationTime;

@property (strong, nonatomic) IBOutlet UIButton *sportStartButton;


@end
