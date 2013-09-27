//
//  WlhyFloatView.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-7.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyFloatView.h"

#import "TTFlowLayout.h"

@implementation WlhyFloatView

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

-(void)layoutSubviews
{
    TTFlowLayout * layout = [[TTFlowLayout alloc] init];
    layout.padding=self.padding;
    layout.spacing=self.spacing;
    
    [layout layoutSubviews:self.subviews forView:self];
}

@end
