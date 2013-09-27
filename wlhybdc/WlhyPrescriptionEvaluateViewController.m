//
//  WlhyPrescriptionEvaluateViewController.m
//  wlhybdc
//
//  Created by ios on 13-7-11.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyPrescriptionEvaluateViewController.h"

@interface WlhyPrescriptionEvaluateViewController ()

@end

@implementation WlhyPrescriptionEvaluateViewController



#pragma mark - VC life

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.title = @"处方评价";
}

- (void)viewWillAppear:(BOOL)animated
{
    [self sendRequest:
     
     @{@"memberId":[DBM dbm].currentUsers.memberId,
     @"pwd":[DBM dbm].currentUsers.pwd}
     
               action:wlGetNoCommentPrescriptionRequest
        baseUrlString:wlServer];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - processRequest

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    
    NSLog(@"action :: %@", action);
    NSLog(@"info :: %@ , error :: %@", info, error);
    
    if(!error){
        NSLog(@"%@",info);
        NSNumber* errorCode = [info objectForKey:@"errorCode"];
        if(errorCode.intValue == 0){
            //成功获取未评价的处方列表：：
            
        }else {
            [self showText:[info objectForKey:@"errorDesc"]];
        }
    }else{
        [self showText:@"连接服务器失败！"];
    }
}

@end
