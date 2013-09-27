//
//  WlhyPostSegue.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-12.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyPostSegue.h"

@implementation WlhyPostSegue

-(void)perform
{
    if([DBM dbm].isLogined){
        postNotification(wlhyShowViewControllerNotification,@{@"Identifier": NSStringFromClass([self.destinationViewController class])
       , @"push":@YES             });
    }else{
        [self.sourceViewController showText:@"您好，请先登录！"];

        postNotification(wlhyShowViewControllerNotification,@{@"Identifier":@"WlhyLoginViewController", @"push":@YES});
    }
}


@end
