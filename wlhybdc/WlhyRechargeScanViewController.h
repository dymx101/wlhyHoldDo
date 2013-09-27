//
//  WlhyRechargeScanViewController.h
//  wlhybdc
//
//  Created by Hello on 13-9-9.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WlhyRechargeZBarDelegate <NSObject>

- (void)finishGetCardCode:(NSString *)barString vCode:(NSString *)vString;
- (void)failedGetBarCode:(NSError *)error;
- (void)cancelZBarScan:(id)sender;

@end



@interface WlhyRechargeScanViewController : UIViewController

@property(strong, nonatomic) id <WlhyRechargeZBarDelegate> delegate;

@end

