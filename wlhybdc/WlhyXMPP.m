    //
//  WlhyXMPP.m
//  wlhybdc
//
//  Created by ios on 13-8-6.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyXMPP.h"

#import <AudioToolbox/AudioToolbox.h>
#import "FileManage.h"

static WlhyXMPP* _WlhyXMPP = nil;


@implementation WlhyXMPP


+ (WlhyXMPP *)WlhyXMPP
{
    if(!_WlhyXMPP){
        _WlhyXMPP = [[self alloc] init];
    }
    return _WlhyXMPP;
}

- (void)connect
{
    
    Users *users = [DBM dbm].currentUsers;
    
    if(!_xmppStream){
        _xmppStream = [[XMPPStream alloc] init];
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_current_queue()];
    }
    _xmppStream.enableBackgroundingOnSocket = YES;
    
    if (![_xmppStream isDisconnected]) {
        return;
    }
    
    _myJID = [NSString stringWithFormat:@"%@@%@", users.phone, users.imServerName];
    [_xmppStream setHostName: users.imUrl];
    [_xmppStream setHostPort:[users.imPort integerValue]];
    [_xmppStream setMyJID:[XMPPJID jidWithString:_myJID]];
    
    NSLog(@"%@ , %i", _xmppStream.hostName, _xmppStream.hostPort);
    
    NSError * error=nil;
    [_xmppStream connect:&error];
    if(error){
        Alert(error.description);
    }
}

- (void)connectWithHostname:(NSString *)kHostName hostPort:(NSString *)kHostPort servername:(NSString *)kServerName
{
    
    if(!_xmppStream){
        _xmppStream = [[XMPPStream alloc] init];
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_current_queue()];
    }
    _xmppStream.enableBackgroundingOnSocket = YES;
    
    if (![_xmppStream isDisconnected]) {
        return;
    }
    
    _myJID = [NSString stringWithFormat:@"%@@%@", @"", kServerName];
    [_xmppStream setHostName: kHostName];
    [_xmppStream setHostPort: [kHostPort integerValue]];
    [_xmppStream setMyJID:[XMPPJID jidWithString:_myJID]];
    
    NSLog(@"%@ , %i", _xmppStream.hostName, _xmppStream.hostPort);
    
    NSError * error=nil;
    [_xmppStream connect:&error];
    if(error){
        Alert(error.description);
    }
}

- (void)setMateToMyTrain
{
    [self setMate:[DBM dbm].usersExt.serviceAccount serverName:[DBM dbm].currentUsers.imServerName];
}

- (void)setMate:(NSString *)kMateID serverName:(NSString *)kServerName
{
    _mateID = kMateID;
    _serverName = kServerName;
}

- (void)disconnect
{
    [self goOffLine];
    [_xmppStream disconnect];
}

- (void)goOnLine
{    
    //发送在线状态
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
    
}

- (void)goOffLine
{
    //发送下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
}

- (void)playMessageSound
{
        
    NSString *path = [[NSBundle mainBundle] pathForResource:@"message" ofType:@"wav"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&soundID);
    AudioServicesPlaySystemSound(soundID);
}

- (void)sendMessage:(NSString *)messageContent
{
    if (messageContent == nil) {
        return;
    }
    if (!_mateID) {
        _mateID = [DBM dbm].usersExt.serviceAccount;
    }
    if (!_serverName) {
        _serverName = [DBM dbm].currentUsers.imServerName;
    }
    
    NSLog(@"_mateID :: %@", _mateID);
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:messageContent];
    //生成XML消息文档
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    //消息类型
    [mes addAttributeWithName:@"type" stringValue:@"chat"];
    //发送给谁
    [mes addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@", _mateID, _serverName]];
    //由谁发送
    //[mes addAttributeWithName:@"from" stringValue:@"test1@linglongmatomacbook.local"];
    //组合
    [mes addChild:body];
    
    //发送消息
    [_xmppStream sendElement:mes];
}

#pragma mark - XMPP XMPPStreamDelegate

- (void)xmppStreamWillConnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamWillConnect");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidConnect");
    
    NSError * error = nil;
    
    [_delegate XMPPDidConnected];
    
    if([DBM dbm].isLogined) {
        [_xmppStream authenticateWithPassword:[DBM dbm].currentUsers.pwd error:&error];
    } else {
        [_xmppStream authenticateAnonymously:&error];
    }
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidRegister");
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    NSLog(@"didNotRegister");
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self goOnLine];
    [_delegate XMPPDidAuthenticate];
    
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"didNotAuthenticate error :: %@", error);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"XMPPMessageDidReceive :: %@", message);
    
    /*
     <message xmlns="jabber:client" id="KT982-56" to="12345678957@218.245.5.76" from="18005313926@218.245.5.76/PtaAndroidClient" type="chat"><subject>JSSJ</subject><body>考虑</body><thread>l0Qnq37</thread></message>
     */
    
    /*
     <message xmlns="jabber:client" id="KT982-59" to="12345678957@218.245.5.76" from="18005313926@218.245.5.76/PtaAndroidClient" type="chat"><body>mark_online_会员在线</body><thread>l0Qnq38</thread></message>
     */
    
    NSString *from = [message fromStr];
    NSString *contentString = [[message elementForName:@"body"] stringValue];
    
    
    if(IsEmptyString(contentString) || [contentString hasPrefix:@"mark_"]){
        return;
    }

    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        //-----------------程序在【前台执行】----------------------
        if (_delegate) {
            //【当前存在消息代理】
            //让代理类去处理该消息
            [_delegate XMPPMessageDidReceive:message];
        } else {
            //【当前没有接受显示消息的类】
            //1.将收到的该条消息保存在本地相应的数据库的未读消息列表中
            //2.播放提示音
            //3.通知首页菜单做出budgeNumber的更新：：
            
            [self playMessageSound];
            
            NSMutableDictionary *messageDataBase;
            NSString *messageDataBasePath = [[FileManage documentsPath] stringByAppendingPathComponent:@"MessageDataBase.chat"];
            NSData *messageData = [NSData dataWithContentsOfFile:messageDataBasePath];
            if (messageData != NULL) {
                messageDataBase = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
            } else {
                messageDataBase = [NSMutableDictionary dictionary];
            }
            NSLog(@"messageDataBase :: %@", messageDataBase);
            
            if ([from hasPrefix:@"messageprovider"]) {
                //系统消息：：
                NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:
                                                   [messageDataBase objectForKey:@"XTXX"]];
                NSMutableArray *messageArray = [NSMutableArray arrayWithArray:[messageDic objectForKey:@"unreadedMessage"]];
                [messageArray addObject:message];
                [messageDic setValue:messageArray forKey:@"unreadedMessage"];
                [messageDataBase setValue:messageDic forKey:@"XTXX"];
            } else if ([message elementForName:@"subject"]) {
                //前台或私教的消息：：
                NSString *fromFlag = [[message elementForName:@"subject"] stringValue];
                if ([fromFlag isEqualToString:@"JSSJ"]) {
                    //来自【私教】：：
                    NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:
                                                [messageDataBase objectForKey:@"JSSJ"]];
                    NSMutableArray *messageArray = [NSMutableArray arrayWithArray:[messageDic objectForKey:@"unreadedMessage"]];
                    [messageArray addObject:message];
                    [messageDic setValue:messageArray forKey:@"unreadedMessage"];
                    [messageDataBase setValue:messageDic forKey:@"JSSJ"];
                } else if ([fromFlag isEqualToString:@"QTJD"]) {
                    //来自【前台】：：
                    NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:
                                                       [messageDataBase objectForKey:@"QTJD"]];
                    NSMutableArray *messageArray = [NSMutableArray arrayWithArray:[messageDic objectForKey:@"unreadedMessage"]];
                    [messageArray addObject:message];
                    [messageDic setValue:messageArray forKey:@"unreadedMessage"];
                    [messageDataBase setValue:messageDic forKey:@"QTJD"];
                }
            }
            
            NSLog(@"messageDataBase :: %@", messageDataBase);
            messageData = [NSKeyedArchiver archivedDataWithRootObject:messageDataBase];
            [[FileManage fileManage] writeData:messageData toFile:messageDataBasePath];
            postNotification(wlhyUpdateBadgeNumberNotification, nil);
        }
        
    } else {
        //------------程序在【后台运行】，收到消息以通知类型来显示--------------
        
        //【当前没有接受显示消息的类】
        //1.将收到的该条消息保存在本地相应的数据库的未读消息列表中
        //2.播放提示音
        //3.通知首页菜单做出budgeNumber的更新：：
        
        NSMutableDictionary *messageDataBase;
        NSString *messageDataBasePath = [[FileManage documentsPath] stringByAppendingPathComponent:@"MessageDataBase.chat"];
        NSData *messageData = [NSData dataWithContentsOfFile:messageDataBasePath];
        if (messageData != NULL) {
            messageDataBase = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
        } else {
            messageDataBase = [NSMutableDictionary dictionary];
        }
        
        if ([from isEqualToString:@"messageprovider"]) {
            //系统消息：：
            NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:
                                               [messageDataBase objectForKey:@"XTXX"]];
            NSMutableArray *messageArray = [NSMutableArray arrayWithArray:[messageDic objectForKey:@"unreadedMessage"]];
            [messageArray addObject:message];
            [messageDic setValue:messageArray forKey:@"unreadedMessage"];
            [messageDataBase setValue:messageDic forKey:@"XTXX"];
        } else if ([message elementForName:@"subject"]) {
            //前台或私教的消息：：
            NSString *fromFlag = [[message elementForName:@"subject"] stringValue];
            if ([fromFlag isEqualToString:@"JSSJ"]) {
                //来自【私教】：：
                NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:
                                                   [messageDataBase objectForKey:@"JSSJ"]];
                NSMutableArray *messageArray = [NSMutableArray arrayWithArray:[messageDic objectForKey:@"unreadedMessage"]];
                [messageArray addObject:message];
                [messageDic setValue:messageArray forKey:@"unreadedMessage"];
                [messageDataBase setValue:messageDic forKey:@"JSSJ"];
            } else if ([fromFlag isEqualToString:@"QTJD"]) {
                //来自【前台】：：
                NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:
                                                   [messageDataBase objectForKey:@"QTJD"]];
                NSMutableArray *messageArray = [NSMutableArray arrayWithArray:[messageDic objectForKey:@"unreadedMessage"]];
                [messageArray addObject:message];
                [messageDic setValue:messageArray forKey:@"unreadedMessage"];
                [messageDataBase setValue:messageDic forKey:@"QTJD"];
            }
        }
        
        messageData = [NSKeyedArchiver archivedDataWithRootObject:messageDataBase];
        [[FileManage fileManage] writeData:messageData toFile:messageDataBasePath];
        postNotification(wlhyUpdateBadgeNumberNotification, nil);
        
        //发送本地通知：：
        NSString *notificationString = [[message elementForName:@"body"] stringValue];
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = notificationString;   //通知主体
        localNotification.soundName = @"crunch.wav";//通知声音
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];//发送通知
        [UIApplication sharedApplication].applicationIconBadgeNumber += 1;
    }
    
    /*
     <message xmlns="jabber:client"
     id="MamR4-45"
     to="12345678957@218.245.5.76"
     from="18005313926@218.245.5.76/PtaAndroidClient"
     type="chat">
     <subject>JSSJ</subject>
     <body>hello</body><
     thread>Q35Al16</thread>
     </message>
     */
    
    /*
     messageprovider  系统消息
     
     subject
     JSSJ  私教
     QTJD  前台接待
     */
    
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    /*
     <message type="chat" to="12345678912@ay12120201181102f7573"><body>hjbjj</body></message>
     */
    if (!_delegate) {
        return;
    }
    
    [_delegate XMPPMessageDidSend:message];
}


@end
