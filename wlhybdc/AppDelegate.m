//
//  AppDelegate.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-10.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "AppDelegate.h"

#import "FileManage.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    int budgeNumber = 0;
    NSMutableDictionary *messageDataBase;
    NSString *messageDataBasePath = [[FileManage documentsPath] stringByAppendingPathComponent:@"MessageDataBase.chat"];
    NSData *messageData = [NSData dataWithContentsOfFile:messageDataBasePath];
    if (messageData != NULL) {
        messageDataBase = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
    } else {
        messageDataBase = [NSMutableDictionary dictionary];
    }
    
    //系统消息：：
    NSDictionary *messageDic = [messageDataBase objectForKey:@"XTXX"];
    NSArray *messageArray = [messageDic objectForKey:@"unreadedMessage"];
    budgeNumber += messageArray.count;

    //来自【私教】：：
    messageDic = [messageDataBase objectForKey:@"JSSJ"];
    messageArray = [messageDic objectForKey:@"unreadedMessage"];
    budgeNumber += messageArray.count;
    
    //来自【前台】：：
    messageDic = [messageDataBase objectForKey:@"QTJD"];
    messageArray = [messageDic objectForKey:@"unreadedMessage"];
    budgeNumber += messageArray.count;

    application.applicationIconBadgeNumber = budgeNumber;
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//推送与通知：：
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"消息提醒" message:notification.alertBody delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    // 图标上的数字减1
    application.applicationIconBadgeNumber += 1;
}


@end
