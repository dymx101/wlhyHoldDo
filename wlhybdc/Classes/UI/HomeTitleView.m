//
//  HomeTitleView.m
//  wlhybdc
//
//  Created by Hello on 13-9-30.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "HomeTitleView.h"

@interface HomeTitleView ()

@property(strong, nonatomic) IBOutlet UILabel *greetLabel;
@property(strong, nonatomic) IBOutlet UILabel *nameLabel;
@property(strong, nonatomic) IBOutlet UILabel *integralLabel;
@property(strong, nonatomic) IBOutlet UIButton *weatherButton;

@end


@implementation HomeTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"HomeTitleView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        //问候：：
        _greetLabel.text = @"";
        NSDateComponents *dc = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:[NSDate date]];
        NSInteger hour = [dc hour];
        
        if (hour <= 12) {
            _greetLabel.text = @"上午好，";
        } else if (hour <= 18) {
            _greetLabel.text = @"下午好，";
        } else if (hour <= 24) {
            _greetLabel.text = @"晚上好，";
        } else {
            _greetLabel.text = @"您好，";
        }
        
        
        Users * users = [[DBM dbm] currentUsers];
        NSString * title =@"游客";
        if(users){
            if(!IsEmptyString(users.userName)){
                title = users.userName;
            }else {
                title = [users.memberId stringValue];
            }
        }
        
        _nameLabel.text = [NSString stringWithFormat:@"%@",title];
        
        _integralLabel.text = WlhyString([DBM dbm].usersExt.hdi);
        [_weatherButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        
    }
    return self;
}

- (void)updateDisplay
{
    //问候：：
    _greetLabel.text = @"";
    NSDateComponents *dc = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:[NSDate date]];
    NSInteger hour = [dc hour];
    
    if (hour <= 12) {
        _greetLabel.text = @"上午好，";
    } else if (hour <= 18) {
        _greetLabel.text = @"下午好，";
    } else if (hour <= 24) {
        _greetLabel.text = @"晚上好，";
    } else {
        _greetLabel.text = @"您好，";
    }
    
    
    Users * users = [[DBM dbm] currentUsers];
    NSString * title =@"游客";
    if(users){
        if(!IsEmptyString(users.userName)){
            title = users.userName;
        }else {
            title = [users.memberId stringValue];
        }
    }
    
    _nameLabel.text = [NSString stringWithFormat:@"%@",title];
    
    _integralLabel.text = WlhyString([DBM dbm].usersExt.hdi);
}

@end
