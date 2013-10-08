//
//  WlhyRechargeErrorViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-12.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyRechargeErrorViewController.h"

@interface WlhyRechargeErrorViewController ()


@property(strong, nonatomic) IBOutlet UILabel *destLabel;
@property(strong, nonatomic) IBOutlet UITextView *introTextView;


- (IBAction)gotoWaiter:(id)sender;
- (IBAction)recharge:(id)sender;

@end

@implementation WlhyRechargeErrorViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"账户激活";
    
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

- (void)viewWillAppear:(BOOL)animated
{
    _destLabel.text = _desc;
    _introTextView.text = @"（1）实时、专业的指导\n（2）持续的督促与推进\n（3）个性化的健身服务\n（4）健身之路最佳搭档";
}

- (void)viewDidUnload
{
    
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.destLabel = nil;
        self.introTextView = nil;
    }
    
}

- (void)back:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    [self.navigationController popViewControllerAnimated:NO];
}

@end
