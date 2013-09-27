//
//  WlhyLauncherViewController.h
//  wlhybdc
//
//  Created by linglong meng on 12-11-20.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NILauncherViewController.h"
#import "NILauncherButtonView.h"
#import "NILauncherViewObject.h"

@class NIBadgeView;

/**
 * A subclass of NILauncherViewObject that provides badging support.
 *
 * Adding this type of object to a NILauncherViewModel will create a BadgedLauncherButtonView view.
 */
@interface BadgedLauncherViewObject : NILauncherViewObject

@property (nonatomic, readwrite, assign) NSInteger badgeNumber;

@property(nonatomic,retain) NSString* targer;

- (id)initWithTitle:(NSString *)title image:(UIImage *)image badgeNumber:(NSInteger)badgeNumber tager:(NSString*)tager;
+ (id)objectWithTitle:(NSString *)title image:(UIImage *)image badgeNumber:(NSInteger)badgeNumber tager:(NSString*)tager;

@end

//====================================================================================================
//====================================================================================================

/**
 * A launcher button view that displays a badge number.
 *
 * The badge is hidden if the number is 0.
 * The badge displays 99+ if the number is greater than 99.
 */

@interface BadgedLauncherButtonView : NILauncherButtonView

@property (nonatomic, readwrite, retain) NIBadgeView* badgeView;

@end


@interface WlhyLauncherViewController : NILauncherViewController

- (void)updateBadgeNumbers:(NSArray *)badgeNumbers;

@end
