//
//  WlhyMuitableSelectView.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-7.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyMuitableSelectView.h"
#import "TTGridLayout.h"
#import "CMPopTipView.h"

@implementation WlhyMuitableSelectView

@synthesize jsonArray=_jsonArray;
@synthesize selectedIndexs=_selectedIndexs;
@synthesize selectedIndexString=_selectedIndexString;

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
-(void)setJsonArray:(NSString *)jsonArray
{
    if(![_jsonArray isEqualToString:jsonArray]){
        _jsonArray = jsonArray;
    }
    for(UIView * view in self.subviews){
        [view removeFromSuperview];
    }
    
    NSArray * array  = JSONObjectFromString(_jsonArray);
    for (int i = 0; i < array.count; i++) {
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectZero];
        button.tag=i+1;
        button.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        [button setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateNormal];
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font=[UIFont systemFontOfSize:14];
        button.titleLabel.lineBreakMode=UILineBreakModeCharacterWrap;
        button.titleLabel.numberOfLines=2;
        [button setImage:[UIImage imageNamed:@"checkbox_empty"] forState:UIControlStateSelected];
        [button setTitle:[NSString stringWithFormat:@"%@",[array objectAtIndex:i]]forState:UIControlStateNormal];
        
        [self addSubview:button];
        
        [button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self setNeedsLayout];
}


-(void)setSelectedIndexs:(NSMutableArray *)selectedIndexs
{
    if(_selectedIndexs != selectedIndexs){
        _selectedIndexs = selectedIndexs;
    }
    for (id n in _selectedIndexs) {
        UIView * view  = [self viewWithTag:[n integerValue]];
        if([view isKindOfClass:[UIButton class]]){
            [(UIButton*)view setSelected:YES];
        }
    }
}

-(void)layoutSubviews
{
    TTGridLayout * layout = [[TTGridLayout alloc] init];
    layout.spacing=self.spacing;
    layout.padding=self.padding;
    layout.columnCount=self.columnCount;
    [layout layoutSubviews:self.subviews forView:self];
}

-(void)buttonTouched:(id)sender
{
    if(self.maxSelected>0 && self.maxSelected <= self.selectedIndexs.count && ![sender isSelected]){

        CMPopTipView *tipVIew = [[CMPopTipView alloc] initWithMessage:[NSString stringWithFormat:@"最多只能选择%d项",self.maxSelected]];
        tipVIew.textColor=[UIColor redColor];
        
        UIView *v  = [self findFirstResponder];
        if(!v){
            v = [UIApplication sharedApplication].keyWindow;
        }
        
        tipVIew.dismissTapAnywhere=YES;
        [tipVIew presentPointingAtView:sender inView:v  animated:YES];

        return;
    }
    [sender setSelected:![sender isSelected]];
    [self updateSelectedIndexs];

}

-(void)updateSelectedIndexs
{
    if(!_selectedIndexs){
        _selectedIndexs = [NSMutableArray array];
    }
    [_selectedIndexs removeAllObjects];
    for (UIView * view in self.subviews) {
        if([view isKindOfClass:[UIButton class]]){
            if([(UIButton*)view isSelected]){
                [_selectedIndexs addObject:[NSNumber numberWithInteger:view.tag]];
            }
        }
    }
    
}


-(NSString*)selectedIndexString
{
    NSMutableString * str = [NSMutableString string];
    
    [self updateSelectedIndexs];
    
    for (id v in _selectedIndexs) {
        if(str.length ==0){
            [str appendString:[NSString stringWithFormat:@"%@",v]];
        }else{
            [str appendString:[NSString stringWithFormat:@",%@",v]];
        }
    }
    return str;
}

@end
