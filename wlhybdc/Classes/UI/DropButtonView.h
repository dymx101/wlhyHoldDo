//
//  DropButtonView.h
//  wlhybdc
//
//  Created by Hello on 13-9-18.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DropButtonViewDelegate <NSObject>

- (void)dropButtonTapped:(id)sender;

@end



@interface DropButtonView : UIView

@property(strong, nonatomic) id <DropButtonViewDelegate> delegate;

@end
