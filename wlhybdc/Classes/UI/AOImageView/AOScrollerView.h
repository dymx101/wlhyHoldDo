//
//  AOScrollerView.h
//  AOImageViewDemo
//
//  Created by akria.king on 13-4-2.
//  Copyright (c) 2013年 akria.king. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AOImageView.h"

#define rightDirection 1
#define leftDirection 0

@protocol ValueClickDelegate <NSObject>

-(void)buttonClick:(int)vid;

@end




@interface AOScrollerView : UIView <UIScrollViewDelegate,UrLImageButtonDelegate>

@property(nonatomic,strong)id<ValueClickDelegate> vDelegate;

- (void)setNameArr:(NSMutableArray *)imageArr titleArr:(NSMutableArray *)titleArr;

@end
