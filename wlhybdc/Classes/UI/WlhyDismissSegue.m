//
//  WlhyDismissSegue.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-29.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyDismissSegue.h"

@implementation WlhyDismissSegue

-(void)perform
{
    [self.sourceViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
