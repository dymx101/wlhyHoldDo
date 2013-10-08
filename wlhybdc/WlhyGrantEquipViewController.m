//
//  WlhyGrantEquipViewController.m
//  wlhybdc
//
//  Created by Hello on 13-9-17.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyGrantEquipViewController.h"

@interface WlhyGrantEquipViewController ()

@property (strong, nonatomic) IBOutlet WlhyUITextFieldDelegate *wlhyTextDelegate;
@property (strong, nonatomic) IBOutlet WlhyTextField *phoneNumberField;
@property (strong, nonatomic) IBOutlet UITextField *dayField;
@property (strong, nonatomic) IBOutlet UILabel *barDecodeLabel;

- (IBAction)grantButtonTapped:(id)sender;
- (IBAction)cancelInput:(id)sender;

@end

@implementation WlhyGrantEquipViewController

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

    self.title = @"器械授权";
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _barDecodeLabel.text = _barDecode;
    [_phoneNumberField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.wlhyTextDelegate = nil;
        self.phoneNumberField = nil;
        self.dayField = nil;
        self.barDecode = nil;
        self.barDecodeLabel = nil;
    }
    
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)grantButtonTapped:(id)sender
{
    if (_phoneNumberField.text.length <= 0 || _dayField.text.length <= 0) {
        [self showText:@"您输入的授权信息有误"];
        return;
    }
    if (![_phoneNumberField validate]) {
        return;
    }
    
    /*
     memberid
     pwd
     grant2phone
     day
     barcodeid
    */
    
    [self sendRequest:
     
     @{
     @"memberid": [DBM dbm].currentUsers.memberId,
     @"pwd": [DBM dbm].currentUsers.clearPwd,
     @"grant2phone": _phoneNumberField.text,
     @"day": _dayField.text,
     @"barcodeid": _barDecode
     }
     
               action:wlGrantEquipToOtherRequest
        baseUrlString:wlServer];
}

- (IBAction)cancelInput:(id)sender
{
    [self.view endEditing:NO];
}

#pragma mark - Process Request

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"back action :: %@", action);
    NSLog(@"info :: %@ , error :: %@", info, error);
    
    if ([action isEqualToString:wlGrantEquipToOtherRequest]) {
        if(info){
            if([[info objectForKey:@"errorCode"] intValue] == 0) {
                [self showText:@"器械授权成功"];
                [self performSelector:@selector(back:) withObject:nil afterDelay:1.5f];
            } else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
        }else{
            [self showText:@"连接服务器失败！"];
        }
    }
    
}

@end
