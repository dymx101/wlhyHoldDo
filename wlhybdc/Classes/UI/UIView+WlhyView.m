//
//  UIView+WlhyView.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-12.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "UIView+WlhyView.h"

@implementation UIView (WlhyView)


- (UIView*)findFirstResponder
{
    return [self findFirstResponderInView:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)findFirstResponderInView:(UIView*)topView
{
    if ([topView isFirstResponder]) {
        return topView;
    }
    
    for (UIView* subView in topView.subviews) {
        if ([subView isFirstResponder]) {
            return subView;
        }
        
        UIView* firstResponderCheck = [self findFirstResponderInView:subView];
        if (nil != firstResponderCheck) {
            return firstResponderCheck;
        }
    }
    return nil;
}

- (void)removeAllSubViews
{
    for (id temp in self.subviews) {
        if ([temp isKindOfClass:[UIView class]] || [temp isKindOfClass:[UIControl class]]) {
            [temp removeFromSuperview];
        }
    }
}

- (id)firstAvailableUIViewController
{
    // convenience function for casting and to "mask" the recursive function
    return [self traverseResponderChainForUIViewController];
}

- (id)traverseResponderChainForUIViewController
{
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}


@end
