//
//  SportGuideMessageView.m
//  wlhybdc
//
//  Created by Hello on 13-9-18.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "SportGuideMessageView.h"

@interface SportGuideMessageView ()

@property(strong, nonatomic) UITextView *contextTextView;
@property(strong, nonatomic) UIView *boardView;

@end


@implementation SportGuideMessageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        _boardView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 80)];
        
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 24, 50, 50)];
        [headImageView setImage:[UIImage imageNamed:@"head_pro.png"]];
        _boardView.layer.cornerRadius = 4.0f;
        _boardView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
        _boardView.layer.borderWidth = 1.0f;
        [_boardView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.9]];
        [_boardView addSubview:headImageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 84, 20)];
        label.text = @"【私教消息】";
        label.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.9 alpha:1.0f];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:14.0f];
        [_boardView addSubview:label];
        
        _contextTextView = [[UITextView alloc] initWithFrame:CGRectMake(63, 24, 228, 50)];
        _contextTextView.textColor = [UIColor darkGrayColor];
        _contextTextView.backgroundColor = [UIColor whiteColor];
        _contextTextView.editable = NO;
        [_contextTextView setFont:[UIFont systemFontOfSize:12.0f]];
        [_boardView addSubview:_contextTextView];
        
        [self addSubview:_boardView];
        
    }
    return self;
}


- (void)setMessageContent:(NSString *)messageContent
{
    _contextTextView.text = messageContent;
    [self performSelector:@selector(dismissThisView:) withObject:nil afterDelay:5.0f];
}

- (void)dismissThisView:(id)sender
{
    
    CATransition *switchAnimation = [CATransition animation];
    switchAnimation.delegate = self;
    switchAnimation.duration = 2.0;
    switchAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
    switchAnimation.type = @"fade";
    switchAnimation.subtype = @"fromTop";
    //@"cube" @"moveIn" @"reveal" @"fade" @"pageCurl" @"pageUnCurl" @"suckEffect" @"rippleEffect" @"oglFlip"
    [self removeFromSuperview];
    
    [[self layer] addAnimation:switchAnimation forKey:@"mySwitch"];
    
}

@end

