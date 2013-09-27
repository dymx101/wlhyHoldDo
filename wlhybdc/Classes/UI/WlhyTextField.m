//
//  WlhyTextField.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-12.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyTextField.h"
#import "CMPopTipView.h"

@implementation WlhyTextField
@synthesize validator=_validator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(BOOL)validate{
    NSError *error = nil;
    BOOL validateResult = [_validator validateInput:self error:&error];
    if(!validateResult){
        NSDictionary * info = error.userInfo;
        CMPopTipView *tipVIew = [[CMPopTipView alloc] initWithMessage:[NSString stringWithFormat:@"%@,%@",[info objectForKey:NSLocalizedDescriptionKey],[info objectForKey:NSLocalizedFailureReasonErrorKey]]];
        tipVIew.textColor=[UIColor redColor];
        
        UIView *v  = [self findFirstResponder];
        if(!v){
            v = [UIApplication sharedApplication].keyWindow;
        }
        
        tipVIew.dismissTapAnywhere=YES;
        [tipVIew presentPointingAtView:self inView:v  animated:YES];
    }
    return validateResult;
}

@end
