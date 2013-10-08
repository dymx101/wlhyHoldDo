//
//  DatePickerView.m
//  wlhybdc
//
//  Created by Hello on 13-10-8.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "DatePickerView.h"

#import "WlhyDateTextField.h"

@interface DatePickerView ()
{
    float spaceToViewBottom;
    
    CGRect _preRect;
    BOOL _isShowkeyBord;
}

@property (strong, nonatomic) IBOutlet UIView *commentBGView;
@property(strong, nonatomic) IBOutlet WlhyDateTextField *startDateField;
@property(strong, nonatomic) IBOutlet WlhyDateTextField *endDateField;

- (IBAction)OKButtonTapped:(id)sender;
- (IBAction)cancelInput:(id)sender;

@end


@implementation DatePickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DatePickerView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _commentBGView.layer.cornerRadius = 4;
        _commentBGView.layer.borderWidth = 1;
        _commentBGView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;
        
        spaceToViewBottom = self.frame.size.height - (_commentBGView.frame.origin.y + _commentBGView.frame.size.height) + 50;
        
    }
    return self;
}


- (IBAction)OKButtonTapped:(id)sender
{
    [_commentBGView endEditing:NO];
    [_delegate didEnsureDatePickerView:self WithstartDate:_startDateField.text endDate:_endDateField.text];
}

- (IBAction)cancelInput:(id)sender
{
    [_commentBGView endEditing:NO];
    [_delegate didCancelDatePickerView:self];
}



@end
