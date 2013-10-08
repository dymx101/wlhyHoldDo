//
//  WlhyEvaluateEquipViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-12.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyEvaluateEquipViewController.h"

#import "RatingView.h"

@interface WlhyEvaluateEquipViewController ()

@property (strong, nonatomic) IBOutlet WlhyUITextFieldDelegate *wlhyTextDelegate;

@property(strong, nonatomic) IBOutlet RatingView *ratingView;
@property(strong, nonatomic) IBOutlet WlhyTextField *phoneTextField;
@property(strong, nonatomic) IBOutlet UITextView *contentTextView;

- (IBAction)cancleInput:(id)sender;

@end

@implementation WlhyEvaluateEquipViewController

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

    self.title = @"器械评价";
    
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
    
    [_ratingView setImagesDeselected:@"star0.png" partlySelected:@"star1.png" fullSelected:@"star2.png"];
	[_ratingView displayRating:5];
    
    _phoneTextField.text = [DBM dbm].currentUsers.phone;
    
    _contentTextView.layer.cornerRadius = 4;
    _contentTextView.layer.borderWidth = 1;
    _contentTextView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;
    _contentTextView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.75];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.wlhyTextDelegate = nil;
        self.ratingView = nil;
        self.phoneTextField = nil;
        self.contentTextView = nil;
        self.barDecode = nil;
    }
    
    
}

#pragma mark - button Handler

- (void)rightItemTouched:(id)sender
{
    [self cancleInput:nil];
    
    if (_contentTextView.text.length <= 0) {
        [self showText:@"器械评价不能为空"];
        return;
    }
    if (![_phoneTextField validate]) {
        return;
    }
    
    /*
     memberid
     pwd
     barcodeid
     phone
     context
     starLevel
     */
    
    
    //密码为明文
    [self sendRequest:
     
     @{@"memberid": ([DBM dbm].currentUsers.memberId == NULL) ? @"0" : [DBM dbm].currentUsers.memberId,
     @"pwd": ([DBM dbm].currentUsers.clearPwd == NULL) ? @"" : [DBM dbm].currentUsers.clearPwd,
     @"barcodeid": _barDecode,
     @"phone": _phoneTextField.text,
     @"context": _contentTextView.text,
     @"starLevel": [NSString stringWithFormat:@"%i", (int)_ratingView.rating]
     }
     
               action:wlEvaluateEquipRequest
        baseUrlString:wlServer];
    
}

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@,-----,%@",info,error);
    
    if(!error){
            
        if(0 == [[info objectForKey:@"errorCode"] integerValue]) {
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
