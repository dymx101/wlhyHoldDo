//
//  WlhyBodyKPIViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-12.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyBodyKPIViewController.h"

@interface WlhyBodyKPIViewController ()


@property(strong, nonatomic) IBOutlet UILabel *heightLabel;
@property(strong, nonatomic) IBOutlet UILabel *weightLabel;
@property(strong, nonatomic) IBOutlet UILabel *waistLabel;
@property(strong, nonatomic) IBOutlet UILabel *fllLabel;
@property(strong, nonatomic) IBOutlet UILabel *qztzLabel;
@property(strong, nonatomic) IBOutlet UILabel *zfLabel;
@property(strong, nonatomic) IBOutlet UILabel *jrLabel;
@property(strong, nonatomic) IBOutlet UILabel *sfLabel;
@property(strong, nonatomic) IBOutlet UILabel *wjyLabel;
@property(strong, nonatomic) IBOutlet UILabel *dbzLabel;
@property(strong, nonatomic) IBOutlet UILabel *xbnyLabel;
@property(strong, nonatomic) IBOutlet UILabel *xbwyLabel;
@property(strong, nonatomic) IBOutlet UILabel *ssyLabel;
@property(strong, nonatomic) IBOutlet UILabel *szyLabel;
@property(strong, nonatomic) IBOutlet UILabel *xlLabel;
@property(strong, nonatomic) IBOutlet UILabel *updateTimeLabel;

@end

@implementation WlhyBodyKPIViewController

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

    self.title = @"我的身体指标";
    
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
    UsersExt *usersExt = [DBM dbm].usersExt;
    
    _heightLabel.text = WlhyString([usersExt.height stringValue]);
    _weightLabel.text = WlhyString([usersExt.weight stringValue]);
    _waistLabel.text = WlhyString([usersExt.waist stringValue]);
    
    /*
    @property(strong, nonatomic) IBOutlet UILabel *weightLabel;
    @property(strong, nonatomic) IBOutlet UILabel *waistLabel;
    @property(strong, nonatomic) IBOutlet UILabel *fllLabel;
    @property(strong, nonatomic) IBOutlet UILabel *qztzLabel;
    @property(strong, nonatomic) IBOutlet UILabel *zfLabel;
    @property(strong, nonatomic) IBOutlet UILabel *jrLabel;
    @property(strong, nonatomic) IBOutlet UILabel *sfLabel;
    @property(strong, nonatomic) IBOutlet UILabel *wjyLabel;
    @property(strong, nonatomic) IBOutlet UILabel *dbzLabel;
    @property(strong, nonatomic) IBOutlet UILabel *xbnyLabel;
    @property(strong, nonatomic) IBOutlet UILabel *xbwyLabel;
    @property(strong, nonatomic) IBOutlet UILabel *ssyLabel;
    @property(strong, nonatomic) IBOutlet UILabel *szyLabel;
    @property(strong, nonatomic) IBOutlet UILabel *xlLabel;
    @property(strong, nonatomic) IBOutlet UILabel *updateTimeLabel;
    */
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.view = nil;
    self.heightLabel = nil;
    self.weightLabel = nil;
    self.waistLabel = nil;
    self.fllLabel = nil;
    self.qztzLabel = nil;
    self.zfLabel = nil;
    self.jrLabel = nil;
    self.sfLabel = nil;
    self.wjyLabel = nil;
    self.dbzLabel = nil;
    self.xbnyLabel = nil;
    self.xbwyLabel = nil;
    self.ssyLabel = nil;
    self.szyLabel = nil;
    self.xlLabel = nil;
    self.updateTimeLabel = nil;
    
}

#pragma mark - 

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
