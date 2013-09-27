//
//  WlhySecurityCodeButton.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-8.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhySecurityCodeButton.h"

@interface WlhySecurityCodeButton()
{
    NSTimer *_timer;
    NSUInteger _seconds;
    NSUInteger _secondsHold;
    BOOL _isFired;
}

@end

@implementation WlhySecurityCodeButton
@synthesize seconds=_seconds;
@synthesize isFired=_isFired;

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

-(void)dealloc{
    WL_INVALIDATE_TIMER(_timer);
}

-(id)init{
    self = [super init];
    if(self){
        self.autoInvalidata=YES;
        _isFired=NO;
    }
    return self;
}

-(void)setSeconds:(NSUInteger)seconds{
    _seconds=seconds;
    _secondsHold=seconds;
}

-(void)fire{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerExecl) userInfo:nil repeats:YES];
    }
    _seconds = _secondsHold;
    _isFired=YES;
    [_timer fire];
}
-(void)invalidata{
    WL_INVALIDATE_TIMER(_timer);
    [self setTitle:self.title forState:UIControlStateNormal];
    _isFired=NO;
}


-(void)timerExecl{
    if(--_seconds){
        if(IsEmptyString(self.title)){
            self.title=[self titleForState:UIControlStateNormal];
        }
        NSString* msg = nil;
        if(IsEmptyString(self.delayTitle)){
            msg = [NSString stringWithFormat:@"%d秒后再%@",_seconds,self.title];
        }else{
            msg = [NSString stringWithFormat:@"%@(%d)",self.delayTitle,_seconds];
        }
        [self setTitle:msg forState:UIControlStateNormal];
    }else{
        if(self.autoInvalidata){
            [self invalidata];
        }else{
            _seconds=_secondsHold;
        }
    }
}

@end
