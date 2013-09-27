//
//  WlhySportTotalCell.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-31.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhySportTotalCell.h"

@implementation WlhySportTotalCell

@synthesize sportButtonState=_sportButtonState;

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

-(void)setSportButtonState:(SportButtonState)sportButtonState
{
    _sportButtonState=sportButtonState;
    
    switch (sportButtonState) {
        case SportButtonStatePause:
            
            [self.sportStartButton setImage:[UIImage imageNamed:@"sport_b0"] forState:UIControlStateNormal];
            [self.sportStartButton setImage:[UIImage imageNamed:@"sport_b1"] forState:UIControlStateHighlighted];
            
            break;
        case SportButtonStateStop:
            
            [self.sportStartButton setImage:[UIImage imageNamed:@"sport_c0"] forState:UIControlStateNormal];
            [self.sportStartButton setImage:[UIImage imageNamed:@"sport_c1"] forState:UIControlStateHighlighted];
            
            break;
            
        case SportButtonStateStart:
        default:
            [self.sportStartButton setImage:[UIImage imageNamed:@"sport_a0"] forState:UIControlStateNormal];
            [self.sportStartButton setImage:[UIImage imageNamed:@"sport_a1"] forState:UIControlStateHighlighted];
            break;
            
    }
}
@end
