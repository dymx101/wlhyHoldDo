//
//  Users.h
//  wlhybdc
//
//  Created by ios on 13-7-22.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Users : NSManagedObject

@property (nonatomic, retain) NSString * apkUrl;
@property (nonatomic, retain) NSNumber * autologin;
@property (nonatomic, retain) NSString * ftpAccount;
@property (nonatomic, retain) NSString * ftpIp;
@property (nonatomic, retain) NSString * ftpPwd;
@property (nonatomic, retain) NSNumber * imPort;
@property (nonatomic, retain) NSString * imServerName;
@property (nonatomic, retain) NSString * imUrl;
@property (nonatomic, retain) NSDate * lastlogin;
@property (nonatomic, retain) NSNumber * memberId;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * pwd;
@property (nonatomic, retain) NSString * clearPwd;  //明文密码
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * version;

@end
