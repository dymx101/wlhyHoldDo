//
//  WlhyModifyHistoryViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-20.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyModifyHistoryViewController.h"

#import "BrokenLineView.h"

@interface WlhyModifyHistoryViewController ()
{
    float max;
    float min;
}

@property(strong, nonatomic) NSArray *dataArray;
@property(strong, nonatomic) IBOutlet BrokenLineView *brokenLineView;

@end



@implementation WlhyModifyHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"修改历史";
    
    //自定义返回：：
    self.navigationItem.hidesBackButton = YES;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setContentMode:UIViewContentModeScaleToFill];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back_1.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 62, 40);
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    NSString *action = @"";
    
    if ([_scanParam isEqualToString:@"ScanHeight"]) {
        self.title = @"我的身高记录";
        min = 50.0;
        max = 250.0;
        action = wlGetHeightHistoryRequest;
    } else if ([_scanParam isEqualToString:@"ScanWeight"]) {
        self.title = @"我的体重记录";
        min = 10.0;
        max = 300.0;
        action = wlGetWeightHistoryRequest;
    } else if ([_scanParam isEqualToString:@"ScanWaist"]) {
        self.title = @"我的腰围记录";
        min = 40.0;
        max = 200.0;
        action = wlGetWaistHistoryRequest;
    }
    
    [self sendRequest:
     
     @{
     @"memberid": [DBM dbm].currentUsers.memberId,
     @"pwd": [DBM dbm].currentUsers.pwd
     }
     
               action:action
        baseUrlString:wlServer];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self.view window] == nil) {
        self.view = nil;
    }
    
    self.brokenLineView = nil;
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - processRequest

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@---%@",info,error);
    
    if(!error){
        if([[info objectForKey:@"errorCode"] integerValue] == 0){
            
            _dataArray = [info objectForKey:@"list"];
            
            _brokenLineView.max = max;
            _brokenLineView.min = 0.0;
            [_brokenLineView setDataArray:_dataArray];
            
            
        }else if([[info objectForKey:@"errorCode"] integerValue] == 2){
            [self showText:[info objectForKey:@"errorDesc"]];
        }
    }else{
        [self showText:@"连接服务器失败！"];
    }
}



@end
