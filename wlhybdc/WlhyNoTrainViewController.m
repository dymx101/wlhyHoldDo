//
//  WlhyNoTrainViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-14.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyNoTrainViewController.h"

@interface WlhyNoTrainViewController ()

@property(strong, nonatomic) IBOutlet UILabel *descLabel;
@property(strong, nonatomic) IBOutlet UITextView *introTextView;

- (IBAction)gotoWaiter:(id)sender;
- (IBAction)recharge:(id)sender;

@end

@implementation WlhyNoTrainViewController

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
	
    self.title = @"健身私教";
    
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
    [rightButton setTitle:@"查询私教" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_0.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_1.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(self.view.frame.size.width - 70, 0, 66, 40);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    _descLabel.text = _desc;
//    _descLabel.text = @"服务未激活，详情请咨询您的前台或者您的私教人员。";
    _introTextView.text = @"（1）实时、专业的指导\n（2）持续的督促与推进\n（3）个性化的健身服务\n（4）健身之路最佳搭档";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.descLabel = nil;
        self.introTextView = nil;
        
        self.desc = nil;
    }
    
}

- (void)back:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)rightItemTouched:(id)sender
{
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyRechargeViewController"];
    if ([destVC respondsToSelector:@selector(setRechargeVCPurpose:)]) {
        [destVC setValue:[NSNumber numberWithInt:3] forKey:@"rechargeVCPurpose"];
    }
    [self.navigationController pushViewController:destVC animated:NO];
}

- (IBAction)gotoWaiter:(id)sender
{
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyWaiterServiceViewController"];
    if (destVC) {
        [self.navigationController pushViewController:destVC animated:NO];
    }
}

- (IBAction)recharge:(id)sender
{
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyRechargeViewController"];
    if (destVC) {
        [self.navigationController pushViewController:destVC animated:NO];
    }
}

@end
