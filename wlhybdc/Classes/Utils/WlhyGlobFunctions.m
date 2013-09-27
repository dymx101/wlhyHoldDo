//
//  WlhyGlobFunctions.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-12.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyGlobFunctions.h"

#import "sys/utsname.h"

BOOL IsEmptyString(NSString* str){
    return str==nil || str.length==0;
}

NSString *deviceType()
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        CGSize result = [[UIScreen mainScreen] bounds].size;
        
        if(result.height == 480.f) {
            return @"OldScreen";
        } else {
            return @"NewScreen";
        }
    }
    
    return @"PadScreen";
}


NSString * getDateStringWithNSDateAndDateFormat(NSDate *date, NSString *dateFormat)
{
    if (dateFormat == NULL) {
        dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

NSString *getMemberStatus()
{
    NSString *memberStatus = [[DBM dbm] usersExt].memberStatus;
    if ([memberStatus intValue] == 1) {
        return @"正常";
    } else if ([memberStatus intValue] == 2) {
        return @"服务已到期";
    }
    return @"服务未激活";
}

NSString* WlhyString(NSString* str){
    return str==nil ? @"" : str;
}

NSString* GetOSName(){
    UIDevice * device = [UIDevice currentDevice];
    return [NSString stringWithFormat:@"%@ %@",[device systemName],[device systemVersion]];
}

void postNotification(NSString* identifier,NSDictionary *userinfo){
    [[NSNotificationCenter defaultCenter] postNotificationName:identifier object:nil userInfo:userinfo];
}


NSDate* localNow()
{
    // 获取当前UTC时间
    NSDate *now = [NSDate date];
    // 获取当前时区
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    //当前时区与UTC时间的相差秒数
    NSInteger seconds = [tz secondsFromGMTForDate: now];
    //转换为当前时区时间
    return [NSDate dateWithTimeInterval: seconds sinceDate: now];
}

void Alert(NSString* text)
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
    [alert show];
}

NSString * JSONStringFromParameters(NSDictionary *parameters)
{
    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];;
    
    if (!error) {
        return [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

id JSONObjectFromString(NSString* string)
{
    if(IsEmptyString(string)){
        return  nil;
    }
    NSError * error = nil;
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    id ret = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    return ret;
    
}

