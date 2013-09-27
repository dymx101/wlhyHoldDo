//
//  WlhyAdviceInfoViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-23.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyAdviceInfoViewController.h"

@interface WlhyAdviceInfoViewController ()

@property (strong, nonatomic) IBOutlet WlhyUITextFieldDelegate *wlhyTextDelegate;

@property (strong, nonatomic) IBOutlet UIView *inputView;
@property (strong, nonatomic) IBOutlet UITextView *adviceTextView;
@property (strong, nonatomic) IBOutlet WlhyTextField *phoneField;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;

- (IBAction)cancelInput:(id)sender;

@end

@implementation WlhyAdviceInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - VC lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.title = @"意见反馈";
    
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

    _adviceTextView.layer.cornerRadius = 7;
    _adviceTextView.layer.borderWidth = 1;
    _adviceTextView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;
    _adviceTextView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.75];
    
}


- (void)viewDidUnload
{
    [self setAdviceTextView:nil];
    
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


- (void)rightItemTouched:(id)sender
{
    if(IsEmptyString(self.adviceTextView.text)){
        [self showText:@"请输入您要反馈的建议"];
        return;
    }
    [self cancelInput:nil];
    
    [self sendRequest:
     
     @{
     @"memberId" : [DBM dbm].currentUsers.memberId,
     @"adviceContent": self.adviceTextView.text
     }
     
               action:wlInsertAdviceInfo
        baseUrlString:wlServer];
}

#pragma mark - processRequest

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    if(!error){
        if(0 == [[info objectForKey:@"errorCode"] integerValue]){
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        }
        [self showText:WlhyString([info objectForKey:@"errorDesc"])];
    }else{
        [self showText:@"连接服务器失败"];
    }
}

- (IBAction)cancelInput:(id)sender
{
    [self.view endEditing:NO];
}

@end
