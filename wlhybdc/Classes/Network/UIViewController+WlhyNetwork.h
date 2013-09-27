//
//  UIViewController+WlhyNetwork.h
//  wlhybdc
//
//  Created by linglong meng on 12-10-11.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFJSONRequestOperation.h"
#import "UIImageView+AFNetworking.h"

@interface UIViewController (WlhyNetwork)

-(void)showText:(NSString*)text;
-(void)showWithLabel:(NSString*)text;

-(void)removeHub:(BOOL)allHub;

-(AFJSONRequestOperation*)sendRequest:(NSDictionary *)params action:(NSString*) anAction;
-(AFJSONRequestOperation*)sendRequest:(NSDictionary *)params action:(NSString *)anAction baseUrlString:(NSString*)baseUrlString;

-(void)processRequest:(NSString*) action info:(NSDictionary*)info error:(NSError*)error;

-(void)addSubViewController:(UIViewController*) viewController toView:(UIView*)view;

@end
