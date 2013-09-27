//
//  WlhyDateTextField.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-14.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyDateTextField.h"

@interface WlhyDateTextField ()
{
    NSDateFormatter * _dateFormate;
}
@end
@implementation WlhyDateTextField

@synthesize datePicker=_datePicker;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setDatePicker:(UIDatePicker *)datePicker{
    if(_datePicker!=datePicker){
        _datePicker = nil;
        _datePicker=datePicker;
    }
    [_datePicker addTarget:self action:@selector(setDateText) forControlEvents:UIControlEventValueChanged];
    self.inputView=_datePicker;
}

-(void)setDateText{
    if(!_dateFormate){
        _dateFormate = [[NSDateFormatter alloc] init];
        [_dateFormate setDateFormat:@"YYYY-MM-dd"];
    }
    NSDate * d = _datePicker.date;
    if(!d){
        d = [NSDate date];
    }
     self.text=[_dateFormate stringFromDate:d];
}
-(void)awakeFromNib{
    [super awakeFromNib];
    [self setDateText];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
