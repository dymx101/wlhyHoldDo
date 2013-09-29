//
//  WlhyLoginViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-14.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyLoginViewController.h"



@interface WlhyLoginViewController ()

@property (strong, nonatomic) IBOutlet WlhyUITextFieldDelegate *wlhyTextDelegate;

@property (strong, nonatomic) IBOutlet WlhyTextField *username;
@property (strong, nonatomic) IBOutlet WlhyTextField *password;
@property (strong, nonatomic) IBOutlet UISwitch *autoLoginSwitch;

@property(nonatomic)BOOL isLogin;

@property(nonatomic,strong) NSString* pwd;

- (IBAction)autoLoginSwitchHandler:(id)sender;
- (IBAction)cancleInput:(id)sender;
- (IBAction)loginAction:(id)sender;


@end


@implementation WlhyLoginViewController

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
    
    self.title = @"会员登录";
    self.navigationItem.hidesBackButton = YES;
    
    //自定义返回：：
    
    if (_isFromVisitorVC) {
        //自定义返回：：
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setContentMode:UIViewContentModeScaleToFill];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back_1.png"] forState:UIControlStateHighlighted];
        [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        backButton.frame = CGRectMake(0, 0, 62, 40);
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backItem;

    }
    
    _username.keyboardType = UIKeyboardTypeNumberPad;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSDictionary *user = [[DBM dbm] lastLoginUser];
    
    if(user){
        
        NSLog(@"lastLoginUser :: %@ , %@", [user valueForKey:@"phone"], [user valueForKey:@"pwd"]);
        
        NSNumber* autoload = [user valueForKey:@"autologin"];
        if ([autoload boolValue] && [user valueForKey:@"phone"] && [user valueForKey:@"pwd"]) {
            _username.text = [user valueForKey:@"phone"];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
    }
    self.wlhyTextDelegate = nil;
    self.username = nil;
    self.password = nil;
    self.autoLoginSwitch = nil;
    self.isLogin = nil;
    self.pwd = nil;
    self.isFromVisitorVC = nil;
    
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Login

- (IBAction)autoLoginSwitchHandler:(id)sender
{
    [DBM dbm].currentUsers.autologin = [NSNumber numberWithBool:[DBM dbm].currentUsers.autologin];
}

- (IBAction)cancleInput:(id)sender
{
    [[self.tableView findFirstResponder] resignFirstResponder];
}

- (IBAction)loginAction:(id)sender
{
    NSLog(@"%@",@{@"string":@YES});
    
    [self cancleInput:nil];
    if(![self.username validate] || ![self.password validate]){
        return;
    }
  
    self.pwd = self.password.text.md5;
    
    [self sendRequest:@{@"phone":self.username.text,
                         @"phoneType":GetOSName(),
                         @"iemi":[OpenUDID value],
                         @"pwd":self.pwd}
     
               action:wlLogin
        baseUrlString:wlServer];
    
}


#pragma mark - processRequest

-(void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    if(!error){
        NSInteger errCode= [[info objectForKey:@"errorCode"] integerValue];
        if(0==errCode){
            
            //成功登陆：：
            /*
             @property (nonatomic, retain) NSNumber *autologin;
             @property (nonatomic, retain) NSDate * lastlogin;
             @property (nonatomic, retain) NSNumber * memberId;     ***
             @property (nonatomic, retain) NSString * userName;
             @property (nonatomic, retain) NSString * pwd;          ***
             @property (nonatomic, retain) NSString * phone;
             @property (nonatomic, retain) NSString * version;      ***
             @property (nonatomic, retain) NSString * imUrl;        ***
             @property (nonatomic, retain) NSString * imServerName; ***
             @property (nonatomic, retain) NSNumber * imPort;       ***
             @property (nonatomic, retain) NSString * ftpPwd;       ***
             @property (nonatomic, retain) NSString * ftpIp;        ***
             @property (nonatomic, retain) NSString * ftpAccount;   ***
             @property (nonatomic, retain) NSString * apkUrl;       ***
             */
            
            /*
             {
             apkUrl = "http://42.121.106.113:80/bdcServer/DownLoadServlet";
             brmIp = "42.121.106.113";
             changeFlag = 0;
             city = "\U5317\U4eac";
             errorCode = 0;
             errorDesc = "\U767b\U9646\U6210\U529f";
             ftpAccount = admin;
             ftpIp = "42.121.106.113";
             ftpPwd = "hdjs_2013";
             imPort = 5222;
             imServerName = ay12120201181102f7573;
             imUrl = "42.121.106.113";
             isfree = 0;
             memberId = 141;
             pwd = 96e79218965eb72c92a549dd5a330112;
             rechargeUrl = "/bdcServer/";
             serverIp = "";
             serverPort = "";
             telBackpicture = "http://42.121.106.113:80/img/telbackpicture.jpg";
             version = "\U9047\U5230\U65f6\U4fee\U6539";
             }
             */
            
            NSLog(@"login success :: %@", info);
            
            Users *obj = [[DBM dbm] getUserByMemberId:[info valueForKey:@"memberId"]];
            if(!obj){
                obj = [[DBM dbm] createNewRecord:@"Users"];
            }
            
            [[DBM dbm] saveRecord:obj info:info];
            [obj setValue:localNow() forKey:@"lastlogin"];
            [obj setValue:[NSNumber numberWithBool: self.autoLoginSwitch.on] forKey:@"autologin"];
            [obj setValue:self.username.text forKey:@"phone"];
            [obj setValue:self.password.text forKey:@"clearPwd"];
            
            
            [DBM dbm].currentUsers = obj;
            [DBM dbm].isLogined = YES;
            [[DBM dbm] saveContext];
            
            postNotification(wlhyShowViewControllerNotification, @{@"Identifier":@"Message",
                @"select":wlGetMemberInfoRequest});
            [self.navigationController popToRootViewControllerAnimated:YES];

        }else{
            self.isLogin=NO;
        }
        
        NSString* str = [info objectForKey:@"errorDesc"];
        if(!IsEmptyString(str)){
            NSArray * array = [str componentsSeparatedByString:@":"];
            if(array.count ==4){
                [self showText:[NSString stringWithFormat:@"%@\n%@",[array objectAtIndex:1],[array objectAtIndex:3]]];
            }else if(array.count ==2){
                [self showText:[NSString stringWithFormat:@"%@",[array objectAtIndex:1]]];
            }else{
                [self showText:str];
            }
        }else{
            if(!self.isLogin){
                [self showText:@"登陆失败，请重试"];
            }
        }
        
    }else{
        NSLog(@"%@",error);
         [self showText:@"连接服务器失败，请稍后再试"];
    }

}


@end
