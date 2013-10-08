//
//  WlhyRootViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-12.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyRootViewController.h"
#import "UIBubbleTableView.h"


@interface WlhyRootViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *backImage;

@end


@implementation WlhyRootViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.delegate=self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage * navbkg = [UIImage imageNamed:@"nav_bg.png"];   //main_img.png  top_bg.png
    [self.navigationBar setBackgroundImage:navbkg forBarMetrics:UIBarMetricsDefault];
    
    
    CGRect rect = self.view.frame;
    rect.origin.y+=self.navigationBar.frame.size.height;
    rect.size.height-=self.navigationBar.frame.size.height;
    self.backImage.frame = rect;
    [self.view addSubview:self.backImage];
    [self.view sendSubviewToBack:self.backImage];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
