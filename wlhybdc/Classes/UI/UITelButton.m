//
//  UITelButton.m
//  wlhybdc
//
//  Created by Hello on 13-9-23.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "UITelButton.h"

@implementation UITelButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addTarget:self action:@selector(telButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andTelNumber:(NSString *)numberString
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setTelNumber:(NSString *)telNumber
{
    _telNumber = telNumber;
    [self setTitle:_telNumber forState:UIControlStateNormal];
    [self setTitle:_telNumber forState:UIControlStateHighlighted];
    [self setTitle:_telNumber forState:UIControlStateSelected];
}

@end
