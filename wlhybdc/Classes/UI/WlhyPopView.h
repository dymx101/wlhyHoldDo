//
//  WlhyPopView.h
//  wlhybdc
//
//  Created by linglong meng on 12-11-6.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "CMPopTipView.h"


@interface WlhyPopView : UIAlertView

+(id) showWithBlock:(void (^)(void))block ;
@end
