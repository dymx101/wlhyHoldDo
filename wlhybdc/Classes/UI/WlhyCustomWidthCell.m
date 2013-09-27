//
//  WlhyCustomWidthCell.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-16.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyCustomWidthCell.h"

@implementation WlhyCustomWidthCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setFrame:(CGRect)frame{
    if(!self.subLeft){
        frame.origin.x += self.subWidth;
    }
    frame.size.width -= self.subWidth;
    [super setFrame:frame];
}


@end
