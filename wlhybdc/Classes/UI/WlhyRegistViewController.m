//
//  WlhyRegistViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-12.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyRegistViewController.h"

@interface WlhyRegistViewController ()
{
    
}


@property (strong, nonatomic) IBOutlet WlhyTextField *username;
@property (strong, nonatomic) IBOutlet WlhyTextField *password;
@property (strong, nonatomic) IBOutlet WlhyTextField *ensurePassword;


@property (strong, nonatomic) IBOutlet WlhyUITextFieldDelegate *textFieldDelegate;

- (IBAction)registAction:(id)sender;
- (IBAction)cancleInput:(id)sender;

@end


@implementation WlhyRegistViewController


@synthesize username,password,ensurePassword;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - VC life

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"会员注册";
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        [self setUsername:nil];
        [self setPassword:nil];
        [self setEnsurePassword:nil];
        [self setTextFieldDelegate:nil];
    }
    
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IBAction 

- (IBAction)registAction:(id)sender
{
    
    if([self.ensurePassword.text compare:self.password.text] != NSOrderedSame){
        [self showText:@"密码和确认密码不一致"];
        return;
    }
    
    NSLog(@"%@",self.password.text.md5);
    
    [self sendRequest:
    
     @{
     @"phone":self.username.text,
     @"pwd":self.password.text.md5
     }
               action:wlRegist
        baseUrlString:wlServer];
    
}

- (IBAction)cancleInput:(id)sender
{
    [[self.tableView findFirstResponder] resignFirstResponder];
}

#pragma mark - processRequest

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"%@---%@",info,error);
    
    if(!error){
        if([[info objectForKey:@"errorCode"] integerValue] == 0){
            //注册成功：：
            [self processRegistAction:info];
            
        }else {
            [self showText:[info objectForKey:@"errorDesc"]];
        }
    }else{
        [self showText:@"连接服务器失败！"];
    }
    
}

- (void)processRegistAction:(id)info
{
    [self showText:@"注册成功！"];
    NSLog(@"Regist success :: %@", info);
    
    /*
     {
     apkUrl = "http://www.holddo.com:80/bdcServer/DownLoadServlet";
     brmIp = "";
     changeFlag = 0;
     city = "";
     errorCode = 0;
     errorDesc = "\U6ce8\U518c\U6210\U529f";
     ftpAccount = admin;
     ftpIp = "www.holddo.com";
     ftpPwd = admin;
     imPort = 5222;
     imServerName = "218.245.5.76";
     imUrl = "218.245.5.76";
     isfree = 1;
     memberId = 294;
     pwd = "";
     rechargeUrl = "http://www.holddo.com:80/bdcServer/";
     serverIp = "";
     serverPort = "";
     telBackpicture = "http://www.holddo.com:80/img/telbackpicture.jpg";
     version = "";
     }
     */
    
    Users *obj = [[DBM dbm] getUserByMemberId:[info valueForKey:@"memberId"]];
    if(!obj){
        obj = [[DBM dbm] createNewRecord:@"Users"];
        [[DBM dbm] saveRecord:obj info:info];
    }
    
    [obj setValue:localNow() forKey:@"lastlogin"];
    [obj setValue:[NSNumber numberWithBool: YES] forKey:@"autologin"];
    [obj setValue:self.username.text forKey:@"phone"];
    [obj setValue:self.password.text.md5 forKey:@"pwd"];
    [obj setValue:self.password.text forKey:@"clearPwd"];
    
    
    [[DBM dbm] saveContext];
    [DBM dbm].currentUsers = obj;
    [DBM dbm].usersExt = nil;
    [DBM dbm].prescription = nil;
    [DBM dbm].isLogined = YES;
    
    postNotification(wlhyShowViewControllerNotification, @{@"Identifier":@"Message",
                     @"select":wlGetMemberInfoRequest});
    
    [self performSegueWithIdentifier:@"WlhyRegistSucceedSegue" sender:self];
    
}



@end
