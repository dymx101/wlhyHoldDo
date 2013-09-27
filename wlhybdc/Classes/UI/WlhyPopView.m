//
//  WlhyPopView.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-6.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyPopView.h"

@interface WlhyPopView()

@property(nonatomic,copy) void(^dismissBlock)() ;
@end

@implementation WlhyPopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
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

+(id)showWithBlock:(void (^)(void))block{
    WlhyPopView * pop = [[WlhyPopView alloc] initWithFrame:CGRectZero];
    pop.dismissBlock = block;
    [pop show];
    return pop;
}



@end
