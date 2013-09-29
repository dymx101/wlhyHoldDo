//
//  WlhyModifyMemberPwdViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-12-1.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyModifyMemberPwdViewController.h"

@interface WlhyModifyMemberPwdViewController ()

@property (strong, nonatomic) IBOutlet UITextField *oldPwd;
@property (strong, nonatomic) IBOutlet UITextField *pwd;
@property (strong, nonatomic) IBOutlet UITextField *ensurePwd;
@property (strong, nonatomic) IBOutlet WlhyUITextFieldDelegate *textDelete;

- (IBAction)cancleInput:(id)sender;

@end

@implementation WlhyModifyMemberPwdViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"修改登录密码";
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
    }
    self.oldPwd = nil;
    self.pwd = nil;
    self.ensurePwd = nil;
    self.textDelete = nil;
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)rightItemTouched:(id)sender
{
    //提交请求：：
    
    /*
     memberId
     pwd
     pwd_new
    */
    

    [self sendRequest:
     
     @{@"memberId": [DBM dbm].currentUsers.memberId,
     @"pwd": [_oldPwd.text md5],
     @"pwd_new": [_pwd.text md5]
     }
     
               action:wlModifyMemberPwdRequest
        baseUrlString:wlServer];
}


- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@,-----,%@",info,error);
    
    if(!error){
        if([[info objectForKey:@"errorCode"] integerValue] == 0){
            [self showText:@"密码修改成功，请重新登录"];
            
            [self performSelector:@selector(handlerVCChange:) withObject:nil afterDelay:1.5f];
        }
        
    }else{
        [self showText:@"连接服务器失败，请稍后再试..."];
    }
}

- (void)handlerVCChange:(id)sender
{
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyLoginViewController"];
    if(destVC) {
        [self.navigationController pushViewController:destVC animated:YES];
    }
}

- (IBAction)cancleInput:(id)sender
{
    [self.view endEditing:NO];
}

@end
