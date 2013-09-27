//
//  WlhyServiceClauseViewController.h
//  wlhybdc
//
//  Created by Hello on 13-9-12.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WlhyServiceClauseViewControllerDelegate <NSObject>

- (void)agreeServiceClause;
- (void)disagreeServiceClause;

@end

@interface WlhyServiceClauseViewController : UIViewController

@property(strong, nonatomic) id <WlhyServiceClauseViewControllerDelegate> delegate;

@end
