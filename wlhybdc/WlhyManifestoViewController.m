//
//  WlhyManifestoViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-19.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyManifestoViewController.h"

@interface WlhyManifestoViewController ()

@property(strong, nonatomic) IBOutlet UITextView *manifestoTextView;

- (IBAction)cancleInputAction:(id)sender;

@end

@implementation WlhyManifestoViewController

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
	
    self.title = @"编辑健身宣言";
    
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
    
    _manifestoTextView.layer.cornerRadius = 3;
    _manifestoTextView.layer.borderWidth = 1;
    _manifestoTextView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    _manifestoTextView.text = WlhyString([DBM dbm].usersExt.manifesto);;
    [_manifestoTextView becomeFirstResponder];
}

- (void)viewDidUnload
{
    self.manifestoTextView = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    self.manifestoTextView = nil;
    
    [super didReceiveMemoryWarning];
}

- (void)rightItemTouched:(id)sender
{
    NSLog(@"rightItemTouched");
    
    [self.view endEditing:NO];
    
    [self sendRequest:
     
     @{@"memberId": [DBM dbm].currentUsers.memberId,
     @"pwd": [DBM dbm].currentUsers.pwd,
     @"manifesto": _manifestoTextView.text
     }
     
               action:wlUpdateManifestoRequest
        baseUrlString:wlServer];
    
}

#pragma mark - processRequest

-(void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@---%@",info,error);
    
    if(!error){
        if([[info objectForKey:@"errorCode"] integerValue] ==0){
            [self showText:@"健身宣言更新成功"];
            [DBM dbm].usersExt.manifesto = _manifestoTextView.text;
            [self performSelector:@selector(back:) withObject:nil afterDelay:1.5f];
            
        }else {
            [self showText:[info objectForKey:@"errorDesc"]];
        }
    }else{
        [self showText:@"连接服务器失败！"];
    }
    
}

- (IBAction)cancleInputAction:(id)sender
{
    [self.view endEditing:NO];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
