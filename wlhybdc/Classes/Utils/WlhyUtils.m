//
//  WlhyUtils.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-11.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyUtils.h"


NSString* wlhyShowViewControllerNotification = @"com.wlhy.ShowViewControllerNotification";
NSString* wlhyUpdateBadgeNumberNotification = @"com.wlhy.UpdateBadgeNumberNotification";

NSString* wlhyRunSportDataStoryKey = @"com.wlhy.RunSportDataStoryKey";
NSString* wlhyBikeSportDataStoryKey = @"com.wlhy.BikeSportDataStoryKey";
NSString* wlhyStrengthSportDataStoryKey = @"com.wlhy.StrengthSportDataStoryKey";


static WlhyUtils* _util = nil;;

@implementation WlhyUtils

+(BOOL)empty:(NSString *)str
{
    return str==nil || str.length==0;
}

+(WlhyUtils*)util
{
    if(!_util){
        _util = [[self alloc] init];
    }
    return _util;
}

-(void) delay:(NSTimeInterval)inter withBlock:(void(^)())block
{
    NSTimer * timer = [NSTimer timerWithTimeInterval:inter target:self selector:@selector(execDelay:) userInfo:block repeats:NO];
    [timer fire];
}

-(void)execDelay:(NSTimer*)timer
{
    if(timer.userInfo){
        void(^block)()=timer.userInfo;
        block();
    }
    
}


@end
