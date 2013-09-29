//
//  WlhyForgotPasswordViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-26.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyForgotPasswordViewController.h"

@interface WlhyForgotPasswordViewController ()

@property (strong, nonatomic) IBOutlet WlhySecurityCodeButton *vCodeButton;
@property (strong, nonatomic) IBOutlet WlhyTextField *phoneTextField;
@property (strong, nonatomic) IBOutlet WlhyTextField *vCodeTextField;

@property(nonatomic,strong) NSString* vCodeString;

-(IBAction)forgotPasswordAction:(id)sender;
- (IBAction)vCodeAction:(id)sender;


@end




@implementation WlhyForgotPasswordViewController

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


    self.title = @"忘记密码";
    
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
    }
    self.vCodeButton = nil;
    self.phoneTextField = nil;
    self.vCodeTextField = nil;
    self.vCodeString = nil;
}


- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)vCodeAction:(id)sender
{
    
    if(![self.phoneTextField validate]){
        return;
    }
    
    WlhySecurityCodeButton * b = (WlhySecurityCodeButton*) sender;
    if(b.isFired){
        return;
    }
    b.title = [b titleForState:UIControlStateNormal];
    b.seconds=40;
    [b fire];
    [self sendRequest:
     
     @{@"phone":WlhyString( self.phoneTextField.text)}
     
               action:wlvCode
        baseUrlString:wlServer];
    
}


-(void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"%@",info);
    if(!error){
        [self showText:[info objectForKey:@"errorDesc"]];
        if (0 ==[[info objectForKey:@"errorCode"]integerValue]){
            if([action isEqualToString:wlvCode]) {
                self.vCodeString=[info objectForKey:@"checkCode"];
            }else if([action isEqualToString:wlGetMemberPwdRequest]){
                NSString* pwd = [info objectForKey:@"pwd"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"获取密码成功" message:[NSString stringWithFormat: @"您的密码已修改为：【%@】,请及时修改",pwd  ] delegate:self cancelButtonTitle:@"修改" otherButtonTitles:@"重新登陆", nil];
                [alertView show];
            }
        }
    }else{
        [self showText:@"连接服务器失败，请稍后再试"];
    }
}


-(IBAction)forgotPasswordAction:(id)sender
{
    
    [self sendRequest:
     @{@"":WlhyString( self.phoneTextField.text)}
     
               action:wlGetMemberPwdRequest
        baseUrlString:wlServer];
}




@end
