//
//  WlhySegue.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-15.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhySegue.h"

@implementation WlhySegue

-(void)perform
{    
    [[self.sourceViewController navigationController] popToRootViewControllerAnimated:YES];
}
@end
