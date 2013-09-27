//
//  WlhyServiceClauseViewController.m
//  wlhybdc
//
//  Created by Hello on 13-9-12.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyServiceClauseViewController.h"

@interface WlhyServiceClauseViewController ()

@property(strong, nonatomic) IBOutlet UITextView *contentTextView;

- (IBAction)agreeTapped:(id)sender;
- (IBAction)disagreeTapped:(id)sender;

@end

@implementation WlhyServiceClauseViewController

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
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"CommonBackground.png"]]];    //不删
    
    _contentTextView.layer.cornerRadius = 4;
    _contentTextView.layer.borderWidth = 1;
    _contentTextView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
}

- (void)viewDidUnload
{
    self.contentTextView = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)agreeTapped:(id)sender
{
    
    [self dismissViewControllerAnimated:NO completion:^{
        [_delegate agreeServiceClause];
    }];

}

- (IBAction)disagreeTapped:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        [_delegate disagreeServiceClause];
    }];
}

@end
