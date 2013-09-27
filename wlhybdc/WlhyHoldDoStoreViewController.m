//
//  WlhyHoldDoStoreViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-18.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyHoldDoStoreViewController.h"

@interface WlhyHoldDoStoreViewController ()

@property(strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WlhyHoldDoStoreViewController

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
    
    self.title = @"慧动商城";
    
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
	
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.taobao.com/"]
                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                       timeoutInterval:10.0f]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
