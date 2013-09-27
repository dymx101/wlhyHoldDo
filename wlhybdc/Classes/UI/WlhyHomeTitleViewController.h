//
//  WlhyHomeTitleViewController.h
//  wlhybdc
//
//  Created by linglong meng on 12-10-16.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WlhyHomeTitleViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *dropDownButton;
- (IBAction)dropDownAction:(id)sender;

- (void)updateDisplay;


@end
