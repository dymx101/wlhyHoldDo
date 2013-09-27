//
//  UserSport.h
//  wlhybdc
//
//  Created by linglong meng on 12-10-25.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserSport : NSManagedObject

@property (nonatomic, retain) NSNumber * finish;
@property (nonatomic, retain) NSString * memberId;
@property (nonatomic, retain) NSNumber * segment;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) NSNumber * continueTime;

@end
