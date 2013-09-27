//
//  WlhyLauncherViewModel.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-20.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyLauncherViewModel.h"

@implementation WlhyLauncherViewModel

-(NSInteger)numberOfColumnsPerPageInLauncherView:(NILauncherView *)launcherView{
    return 3;
}

-(NSInteger)numberOfRowsPerPageInLauncherView:(NILauncherView *)launcherView{
    return 2;
}

@end
