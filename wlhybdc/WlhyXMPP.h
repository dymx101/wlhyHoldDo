//
//  WlhyXMPP.h
//  wlhybdc
//
//  Created by ios on 13-8-6.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMPPFramework.h"

typedef enum {
    AppCurrrentVCHome = 0,
    AppCurrrentVCQTJD = 1,
    AppCurrrentVCJSSJ = 2,
    AppCurrrentVCSport = 3,
    AppCurrrentVCOther = 4
}AppCurrrentVC;


@protocol WlhyXMPPDelegate <NSObject>

- (void)XMPPDidConnected;
- (void)XMPPDidAuthenticate;
- (void)XMPPMessageDidSend:(XMPPMessage *)message;
- (void)XMPPMessageDidReceive:(XMPPMessage *)message;

@end


@interface WlhyXMPP : NSObject <XMPPStreamDelegate>


@property(strong, nonatomic) XMPPStream *xmppStream;
@property(assign, nonatomic) BOOL isAuthenticated;
@property(strong, nonatomic) NSString *hostName;
@property(strong, nonatomic) NSString *hostPort;
@property(strong, nonatomic) NSString *myJID;
@property(strong, nonatomic) NSString *usersID;
@property(strong, nonatomic) NSString *serverName;

@property(strong, nonatomic) NSString *mateID;
@property(assign, nonatomic) id <WlhyXMPPDelegate> delegate;
@property(assign, nonatomic) AppCurrrentVC appCurrrentVC;


+ (WlhyXMPP *)WlhyXMPP;

- (void)setMateToMyTrain;
- (void)setMate:(NSString *)kMateID serverName:(NSString *)kServerName;
- (void)sendMessage:(NSString *)messageContent;

- (void)connect;
- (void)forceConnect;
- (void)disconnect;

- (void)goOnLine;
- (void)goOffLine;

- (void)playMessageSound;

@end
