//
//  WlhySecurityCodeButton.h
//  wlhybdc
//
//  Created by linglong meng on 12-10-8.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//


@interface WlhySecurityCodeButton : UIButton

@property(nonatomic,assign) NSUInteger seconds;
@property(nonatomic,strong) NSString* title;
@property(nonatomic,strong) NSString* delayTitle;
@property(nonatomic,readonly) BOOL isFired;
@property(nonatomic,assign) BOOL autoInvalidata;

-(void) fire;
-(void) invalidata;
@end
