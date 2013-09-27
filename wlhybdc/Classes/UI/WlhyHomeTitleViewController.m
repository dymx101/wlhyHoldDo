//
//  WlhyHomeTitleViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-16.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyHomeTitleViewController.h"

typedef enum {
    WlhyDropTypeUp=0,
    WlhyDropTypeDown
} WlhyDropType;

@interface WlhyHomeTitleViewController ()
{
    CGFloat _mvSpace;
}


@property(nonatomic) WlhyDropType dropStatus;

@property(strong, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property(strong, nonatomic) IBOutlet UILabel *totalEnergyLabel;


@end

@implementation WlhyHomeTitleViewController
@synthesize dropStatus=_dropStatus;

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
	// Do any additional setup after loading the view.
    CGRect r= self.view.frame;
    CGRect rb = self.dropDownButton.frame;
    _mvSpace = rb.origin.y;
    r.origin.y -=  _mvSpace;

    self.view.frame = r;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.view = nil;
    self.totalTimeLabel = nil;
    self.totalEnergyLabel = nil;
    self.dropDownButton = nil;
}


#pragma mark - UI

- (void)setUI
{
    [self.dropDownButton setImage:[UIImage imageNamed:@"top_switcher_collapsed"] forState:UIControlStateNormal];
    [self.dropDownButton setImage:[UIImage imageNamed:@"top_switcher_collapsed_selected"] forState:UIControlStateSelected];
    [self.dropDownButton setImage:[UIImage imageNamed:@"top_switcher_collapsed_focused"] forState:UIControlStateHighlighted];
}

- (void)updateDisplay
{
    UsersExt *usersExt = [[DBM dbm] usersExt];
    
    _totalTimeLabel.text = [NSString stringWithFormat:@"%@(H)", WlhyString(usersExt.totalTime)];
    _totalEnergyLabel.text = [NSString stringWithFormat:@"%.2f(kcal)", [usersExt.totalEnergy floatValue]];
}

-(void)setDropStatus:(WlhyDropType)dropStatus
{
    switch (dropStatus) {
        case WlhyDropTypeUp:
            [self.dropDownButton setImage:[UIImage imageNamed:@"top_switcher_collapsed"] forState:UIControlStateNormal];
            
            [self.dropDownButton setImage:[UIImage imageNamed:@"top_switcher_collapsed_selected"] forState:UIControlStateSelected];
            
            [self.dropDownButton setImage:[UIImage imageNamed:@"top_switcher_collapsed_focused"] forState:UIControlStateHighlighted];
        {
            CALayer*l =  self.view.layer;
            CGPoint p = l.position;
            l.position=CGPointMake(l.position.x, l.position.y-_mvSpace);
            [l addAnimation:[NSBKeyframeAnimation animationWithKeyPath:@"position.y" duration:0.8 startValue:p.y endValue:l.position.y function:NSBKeyframeAnimationFunctionEaseOutBounce] forKey:@"position.y"];

        }
            
            break;
        case WlhyDropTypeDown:
            [self.dropDownButton setImage:[UIImage imageNamed:@"top_switcher_expanded"] forState:UIControlStateNormal];
            
            [self.dropDownButton setImage:[UIImage imageNamed:@"top_switcher_expanded_selected"] forState:UIControlStateSelected];
            
            [self.dropDownButton setImage:[UIImage imageNamed:@"top_switcher_expanded_focused"] forState:UIControlStateHighlighted];
        {
            CALayer*l =  self.view.layer;
            CGPoint p = l.position;
            l.position=CGPointMake(l.position.x, l.position.y+_mvSpace);
            [l addAnimation:[NSBKeyframeAnimation animationWithKeyPath:@"position.y" duration:0.8 startValue:p.y endValue:l.position.y function:NSBKeyframeAnimationFunctionEaseOutBounce] forKey:@"position.y"];
            
        }
            
            break;
        default:
            break;
    }
    
    _dropStatus=dropStatus;
}

- (IBAction)dropDownAction:(id)sender
{
    self.dropStatus=!self.dropStatus;
}


@end
