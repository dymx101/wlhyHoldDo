//
//  WlhyZBarViewController.h
//  wlhybdc
//
//  Created by Hello on 13-9-5.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ZBarForEquipInfo = 1,
    ZBarForSport = 2,
}ZBarPurpose;



@protocol WlhyZBarDelegate <NSObject>

- (void)finishGetBarCode:(NSString *)barString;
- (void)failedGetBarCode:(NSError *)error;
- (void)cancelZBarScan:(id)sender;

@end



@interface WlhyZBarViewController : UIViewController

@property(strong, nonatomic) NSNumber *purposeTag;
@property(strong, nonatomic) id <WlhyZBarDelegate> delegate;

@end
