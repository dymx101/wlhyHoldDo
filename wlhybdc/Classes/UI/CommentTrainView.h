//
//  CommentTrainView.h
//  wlhybdc
//
//  Created by Hello on 13-9-22.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentTrainViewDelegate <NSObject>

- (void)finishCommentList:(NSInteger)index content:(NSString *)contentString;

@end



@interface CommentTrainView : UIView

@property(strong, nonatomic) id <CommentTrainViewDelegate> delegate;

@end
