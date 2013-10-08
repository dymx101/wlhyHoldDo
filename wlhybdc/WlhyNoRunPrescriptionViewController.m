//
//  WlhyNoPrescViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-2.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyNoRunPrescriptionViewController.h"

@interface WlhyNoRunPrescriptionViewController ()

@property(strong, nonatomic) IBOutlet UILabel *descLabel;
@property(strong, nonatomic) IBOutlet UITextView *introTextView;
@property(strong, nonatomic) IBOutlet UIView *commonPrescView;


@end




@implementation WlhyNoRunPrescriptionViewController


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
    
    self.title = @"今日处方";
    
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
    
    _descLabel.numberOfLines = 0;
    
    UIViewController *commonPrescVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyCommonPrescViewController"];
    if (commonPrescVC) {
        [self addSubViewController:commonPrescVC toView:_commonPrescView];
    }
    
}


- (void)viewWillAppear:(BOOL)animated
{
    _descLabel.text = _desc;
    _introTextView.text = @"（1）科学有效，安全保障\n（2）个性化量身定制\n（3）持续动态优化\n（4）较少时间可获得较高健康效益";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.descLabel = nil;
        self.introTextView = nil;
        self.desc = nil;
        self.commonPrescView = nil;
    }
    
}


- (void)back:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
