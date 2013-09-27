//
//  Prescription.h
//  wlhybdc
//
//  Created by linglong meng on 12-11-2.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Prescription : NSManagedObject

@property (nonatomic, retain) NSString * prescriptionId;
@property (nonatomic, retain) NSNumber * plannedGoal;
@property (nonatomic, retain) NSString * exerciseGoals;
@property (nonatomic, retain) NSString * exerciseProgram;
@property (nonatomic, retain) NSString * tips;
@property (nonatomic, retain) NSString * friendTips;
@property (nonatomic, retain) NSNumber * memberId;

/*
 {
 errorCode = 0;
 errorDesc = "\U67e5\U8be2\U5904\U65b9\U6982\U51b5\U6210\U529f";
 exerciseGoals = "\U63d0\U9ad8\U5fc3\U80ba\U529f\U80fd";
 exerciseProgram = "1\U3001\U8dd1\U6b65\U673a";
 friendTips = "\U6309\U7167\U5904\U65b9\U63a8\U8350\U7684\U6b21\U5e8f\U8fdb\U884c\U5065\U8eab\U80fd\U5927\U5e45\U5ea6\U63d0\U9ad8\U5065\U8eab\U7684\U6548\U679c\Uff0c\U907f\U514d\U8fd0\U52a8\U4f24\U5bb3\U3002";
 plannedGoal = 5;
 prescriptionId = "1d2a9fda-7bc4-44bf-80c2-b6d0e79b9f6f";
 restflag = 1;
 tips = "\U8981\U575a\U6301\U79d1\U5b66\U6709\U89c4\U5f8b\U7684\U8fd0\U52a8\Uff0c\U5426\U5219\U52a8\U4e0d\U5982\U4e0d\U52a8\U3002";
 }
 */

@end
