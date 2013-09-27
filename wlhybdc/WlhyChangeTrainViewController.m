//
//  WlhyChangeTrainViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-16.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyChangeTrainViewController.h"


@interface WlhyChangeTrainViewController ()

@property(strong, nonatomic) IBOutlet UILabel *currentNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *goalNameLabel;
@property(strong, nonatomic) IBOutlet UITextView *inputTextView;

@end

@implementation WlhyChangeTrainViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"更改私教";
    
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
    
    //右侧按钮：：
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setContentMode:UIViewContentModeScaleToFill];
    [rightButton setTitle:@"提交" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_0.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_1.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(self.view.frame.size.width - 70, 0, 66, 40);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _inputTextView.layer.cornerRadius = 5;
    _inputTextView.layer.borderWidth = 1;
    _inputTextView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
}


- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"_changeDic :: %@", _changeDic);
    
    /*
     {
     EMail = 33500000000;
     account = 33500000000;
     city = "";
     contactWay = "";
     deptName = "wangm\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
     deptid = 001003015;
     eMail = 33500000000;
     enabled = "";
     locked = "";
     password = "";
     picture = "http://www.holddo.com:80/bdcServer/img/personaltrainer/33500000000.jpg";
     province = "";
     remark = "";
     sex = 2;
     specialSkill = "";
     userId = 181;
     userName = "\U79c1\U65590815";
     userQQ = 33500000000;
     userStaticTel = "";
     userTel = "";
     userType = 0;
     worktime = "";
     }
     */
    
    _currentNameLabel.text = WlhyString([DBM dbm].usersExt.serviceName);
    if (_changeDic) {
        _goalNameLabel.text = [_changeDic objectForKey:@"trainName"];
    }
}

- (void)viewDidUnload
{
    self.currentNameLabel = nil;
    self.goalNameLabel = nil;
    self.inputTextView = nil;
    self.changeDic = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backToHome:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)viewTouched:(id)sender
{
    [_inputTextView resignFirstResponder];
}

- (void)rightItemTouched:(id)sender
{
    //提交：：
    
    /*
     memberid
     member_deptId
     src_trnid
     tar_trnid
     tar_trnphone
     chg_cause
    */
    
    [self sendRequest:
     
     @{@"memberid":[DBM dbm].currentUsers.memberId,
     @"member_deptId": [DBM dbm].usersExt.deptid,
     @"src_trnid": [DBM dbm].usersExt.servicePersonId,
     @"tar_trnid": [_changeDic objectForKey:@"trainId"],
     @"tar_trnphone": [_changeDic objectForKey:@"account"],
     @"chg_cause": _inputTextView.text
     }
     
               action:wlChangeTrainRequest
        baseUrlString:wlServer];
}

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@,-----,%@",info,error);
    
    if(!error){
        if(0 == [[info objectForKey:@"errorCode"] integerValue]){
            //返回数据：：
            [self showText:@"更换私教申请已成功提交"];
            [self performSelector:@selector(backToHome:) withObject:nil afterDelay:1.5f];
            
            
        } else{
            [self showText:[info objectForKey:@"errorDesc"]];
        }
        
    }else{
        [self showText:@"连接服务器失败，请稍后再试..."];
    }
}

@end
