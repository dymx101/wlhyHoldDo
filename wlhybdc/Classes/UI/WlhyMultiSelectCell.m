//
//  WlhyMultiSelectCell.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-6.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyMultiSelectCell.h"
#import "TTGridLayout.h"
@interface WlhyMultiSelectCell(){
    
}
@property(nonatomic,strong)NSArray* selectButtons;
@end

@implementation WlhyMultiSelectCell
@synthesize jsonArray=_jsonArray;

-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.textLabel.textAlignment=UITextAlignmentCenter;
    }
    return self;
}

-(void)setJsonArray:(NSString *)jsonArray{
    if(![_jsonArray isEqualToString:jsonArray]){
        _jsonArray = jsonArray;
    }
    for(UIView * view in self.contentView.subviews){
        [view removeFromSuperview];
    }
    
    NSArray * array  = JSONObjectFromString(_jsonArray);
    for (int i = 0; i < array.count; i++) {
        if(i == 0){
            self.textLabel.text=[NSString stringWithFormat:@"%@",[array objectAtIndex:i]];
            self.textLabel.textColor=[UIColor blackColor];
        }else{
            UIButton * button = [[UIButton alloc] initWithFrame:CGRectZero];
            button.tag=i;
            button.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
            [button setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            [button setImage:[UIImage imageNamed:@"checkbox_empty"] forState:UIControlStateSelected];
            [button setTitle:[NSString stringWithFormat:@"%@",[array objectAtIndex:i]] forState:UIControlStateNormal];
            [self.contentView addSubview:button];
        }
    }
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews{
    CGRect rect = self.frame;
    self.textLabel.frame = CGRectMake(0, 0, rect.size.width, 30);
    self.contentView.frame = CGRectMake(0, 30, rect.size.width, rect.size.height-30);
    
    self.textLabel.text=self.jsonArray;
    NSLog(@"%@",self.contentView);
    if(!IsEmptyString(self.jsonArray)){
        NSArray * a = JSONObjectFromString(self.jsonArray);
        NSLog(@"%@",a);
    }
    TTGridLayout * layout = [[TTGridLayout alloc] init];
    layout.spacing=5;
    layout.padding=5;
    layout.columnCount=3;
    [layout layoutSubviews:self.contentView.subviews forView:self.contentView];
}

@end
