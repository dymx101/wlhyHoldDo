//
//  WlhyUtils.h
//  wlhybdc
//
//  Created by linglong meng on 12-10-11.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WlhyNetworkCommunication.h"
#import "WlhySecurityCodeButton.h"
#import "WlhyTextField.h"
#import "TelnumberValidator.h"
#import "LengthValidator.h"
#import "WlhyUITextFieldDelegate.h"

#import "NSBKeyframeAnimation.h"

#import "WlhyPickerViewController.h"
#import "MBProgressHUD.h"

#import "DBM.h"
#import "MarqueeLabel.h"
#import "WlhyGlobFunctions.h"
#import "OpenUDID.h"

#import "UIView+WlhyView.h"
#import "UIViewController+WlhyNetwork.h"
#import "NSString+WlhyString.h"
#import "UIImage+ScaleToSize.h"

#import "NimbusCore.h"


/* 1001 跑步机 1002 单车 1003 力量训练器 1004 血压计 1005 体重秤 1006 椭圆机*/
typedef enum {
    EquipTypePaoBuJi = 1001,
    EquipTypeDanChe = 1002,
    EquipTypeLiLiangXunLianQi = 1003,
    EquipTypeXueYaJi = 1004,
    EquipTypeTiZhongCheng = 1005,
    EquipTypeTuoYuanJi = 1006
}EquipType;


// glob macs
#define WL_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }
#define COLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]



//globs strings

extern NSString *wlhyShowViewControllerNotification;
extern NSString *wlhyUpdateBadgeNumberNotification;
extern NSString* wlhyRunSportDataStoryKey;
extern NSString* wlhyBikeSportDataStoryKey;
extern NSString* wlhyStrengthSportDataStoryKey;



@interface WlhyUtils : NSObject

+(WlhyUtils*) util;

-(void) delay:(NSTimeInterval)inter withBlock:(void(^)())block;
@end
