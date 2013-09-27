//
//  DropButtonView.m
//  wlhybdc
//
//  Created by Hello on 13-9-18.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "DropButtonView.h"

@interface DropButtonView ()


@property (strong, nonatomic) IBOutlet UIImageView *systemSoundIcon;
@property (strong, nonatomic) IBOutlet UIImageView *trainSoundIcon;

- (IBAction)systemSoundTapped:(id)sender;
- (IBAction)trainSoundTapped:(id)sender;
- (IBAction)scanIntroBook:(id)sender;
- (IBAction)serveTapped:(id)sender;
- (IBAction)shareTapped:(id)sender;


@end

@implementation DropButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DropButtonView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        self.layer.cornerRadius = 4;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;
        
        [self setFrame:CGRectMake(frame.origin.x, frame.origin.y, 116, 148)];
        
    }
    return self;
}


- (IBAction)systemSoundTapped:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [_systemSoundIcon setImage:[UIImage imageNamed:@"systemSound1.png"]];
    } else {
        [_systemSoundIcon setImage:[UIImage imageNamed:@"systemSound0.png"]];
    }
    [_delegate dropButtonTapped:sender];
}

- (IBAction)trainSoundTapped:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [_trainSoundIcon setImage:[UIImage imageNamed:@"trainSound1.png"]];
    } else {
        [_trainSoundIcon setImage:[UIImage imageNamed:@"trainSound0.png"]];
    }
    [_delegate dropButtonTapped:sender];
}

- (IBAction)scanIntroBook:(id)sender
{
    [_delegate dropButtonTapped:sender];
}

- (IBAction)serveTapped:(id)sender
{
    [_delegate dropButtonTapped:sender];
}

- (IBAction)shareTapped:(id)sender
{
    [_delegate dropButtonTapped:sender];
}


@end
