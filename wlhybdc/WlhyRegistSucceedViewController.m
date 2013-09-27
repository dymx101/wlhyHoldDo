//
//  WlhyRegistSucceedViewController.m
//  wlhybdc
//
//  Created by ios on 13-7-19.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyRegistSucceedViewController.h"

@interface WlhyRegistSucceedViewController ()


@end

@implementation WlhyRegistSucceedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - VC life

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"注册成功";
    //自定义返回：：
    self.navigationItem.hidesBackButton = YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction

- (IBAction)backHome:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)makeUpMemberInfo:(id)sender
{
    
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyUserBaseInfoViewController"];
    if([destVC respondsToSelector:@selector(setIsForMakeUpInfo:)]){
        [destVC setValue:@YES forKey:@"isForMakeUpInfo"];
        [self.navigationController pushViewController:destVC animated:YES];
    }
}

@end
