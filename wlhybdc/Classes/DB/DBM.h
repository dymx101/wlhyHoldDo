//
//  DBM.h
//  wlhybdc
//
//  Created by linglong meng on 12-10-14.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Users.h"
#import "Prescription.h"
#import "UsersExt.h"


extern NSString* const kUSERIDKEY;

@interface DBM : NSObject
{
    
}

@property(strong) Users* currentUsers;
@property(strong) Prescription * prescription;
@property(strong) UsersExt * usersExt;


+ (DBM*)dbm;
// login set YES,logout set NO
@property(nonatomic) BOOL isLogined;



//save::
- (id)createNewRecord:(NSString*)tableName;
- (void)saveRecord:(NSManagedObject*)obj info:(NSDictionary*)info;
- (void)saveContext;

//get::
- (id)lastLoginUser;
- (id)getUserByMemberId:(NSString*)memberId;
- (id)getPrescriptionByMemberId:(NSNumber*)memberId;
- (id)getUsersExtByMemberId:(NSNumber*)memberId;
- (id)userExtInfos:(NSString*)memberId;

@end
