//
//  WlhyBuyEquipViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-12.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyBuyEquipViewController.h"

@interface WlhyBuyEquipViewController ()

@property(strong, nonatomic) IBOutlet WlhyUITextFieldDelegate *wlhyTextDelegate;
@property(strong, nonatomic) IBOutlet WlhyTextField *phoneTextField;
@property(strong, nonatomic) IBOutlet UITextView *addressTextView;
@property(strong, nonatomic) IBOutlet UITextView *notesTextView;

- (IBAction)cancleInput:(id)sender;

@end

@implementation WlhyBuyEquipViewController

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

    self.title = @"购买器械";
    
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
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_0.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_1.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(self.view.frame.size.width - 70, 0, 66, 40);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    _phoneTextField.text = [DBM dbm].currentUsers.phone;
    
    _addressTextView.layer.cornerRadius = 4;
    _addressTextView.layer.borderWidth = 1;
    _addressTextView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;
    _addressTextView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.75];
    
    _notesTextView.layer.cornerRadius = 4;
    _notesTextView.layer.borderWidth = 1;
    _notesTextView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;
    _notesTextView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.75];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
    if (self.view.window == nil) {
        self.view = nil;
        self.wlhyTextDelegate = nil;
        self.phoneTextField = nil;
        self.addressTextView = nil;
        self.notesTextView = nil;
        self.barDecode = nil;
    }
    
}

#pragma mark - button Handler

- (void)rightItemTouched:(id)sender
{
    NSLog(@"rightItemTouched");
    
    [self cancleInput:nil];
    
    if (![_phoneTextField validate]) {
        [self showText:@"手机号码填写有误"];
        return;
    }
    if (_addressTextView.text.length <= 0) {
        [self showText:@"收货地址填写有误"];
        return;
    }
    
    /*
     obj.put("memberid", memberid);
     obj.put("barcodeid", barcodeId);
     obj.put("phone", phone);
     obj.put("address", address);
     obj.put("remark", remark);
    */
    
    [self sendRequest:
     
     @{@"memberid": ([DBM dbm].currentUsers.memberId == NULL) ? @"0" : [DBM dbm].currentUsers.memberId,
     @"pwd": ([DBM dbm].currentUsers.clearPwd == NULL) ? @"" : [DBM dbm].currentUsers.clearPwd,
     @"barcodeid": _barDecode,
     @"phone": _phoneTextField.text,
     @"address": _addressTextView.text,
     @"remark": _notesTextView.text
     }
     
               action:wlBuyEquipRequest
        baseUrlString:wlServer];
    
}

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@,-----,%@",info,error);
    
    if(!error){
        
        if([[info objectForKey:@"errorCode"] integerValue] == 0) {
            [self showText:[info objectForKey:@"errorDesc"]];
            [self performSelector:@selector(back:) withObject:nil afterDelay:1.5f];
            
        } else {
            [self showText:[info objectForKey:@"errorDesc"]];
        }
        
    }else{
        [self showText:@"连接服务器失败，请稍后再试..."];
    }
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancleInput:(id)sender
{
    [self.view endEditing:NO];
}

@end
