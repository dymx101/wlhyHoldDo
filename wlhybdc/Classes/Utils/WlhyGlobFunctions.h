//
//  WlhyGlobFunctions.h
//  wlhybdc
//
//  Created by linglong meng on 12-10-12.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <Foundation/Foundation.h>

extern BOOL IsEmptyString(NSString* str);
extern NSString* WlhyString(NSString* str);
extern NSString* GetOSName();

extern NSString *deviceType();
extern NSDate* localNow();
extern NSString* getDateStringWithNSDateAndDateFormat(NSDate *date, NSString *dateFormat);
extern NSString *getMemberStatus();


extern void postNotification(NSString* identifier,NSDictionary *userinfo);

extern void Alert(NSString* text);
extern NSString * JSONStringFromParameters(NSDictionary *parameters);
extern id JSONObjectFromString(NSString* string);