//
//  UIView+WlhyView.h
//  wlhybdc
//
//  Created by linglong meng on 12-10-12.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WlhyView)

- (UIView*)findFirstResponder;

- (UIView*)findFirstResponderInView:(UIView*)topView;

- (void)removeAllSubViews;

- (UIViewController *) firstAvailableUIViewController;
- (id) traverseResponderChainForUIViewController;

@end
