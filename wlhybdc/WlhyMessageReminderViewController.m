//
//  WlhyMessageReminderViewController.m
//  wlhybdc
//
//  Created by ios on 13-7-11.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyMessageReminderViewController.h"

#import "WlhyXMPP.h"
#import "FileManage.h"


#pragma mark - Class WlhyHallMemberCell

@interface WlhySystemMessageCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UILabel *messageContentLabel;
@property(strong, nonatomic) IBOutlet UILabel *messageTimeLabel;
@property(strong, nonatomic) IBOutlet UIImageView *cellBGImageView;


@end


@implementation WlhySystemMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

//=================================================================================
//=================================================================================



@interface WlhyMessageReminderViewController () <WlhyXMPPDelegate>
{
    BOOL isReadedMessage;
}


@property(strong, nonatomic) NSMutableArray *systemMessageArray;
@property(strong, nonatomic) IBOutlet UIView *headerView;

@property(strong, nonatomic) WlhyXMPP *wlhyXmpp;


@end

@implementation WlhyMessageReminderViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        isReadedMessage = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"消息提醒";
    
    //自定义返回：：
    self.navigationItem.hidesBackButton = YES;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setContentMode:UIViewContentModeScaleToFill];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back_1.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 62, 40);
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
    /*
    //右侧按钮：：
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setContentMode:UIViewContentModeScaleToFill];
    [rightButton setTitle:@"清空" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_0.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_1.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(self.view.frame.size.width - 70, 0, 66, 40);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    */ 
     
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setXmppStream];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_wlhyXmpp setDelegate:nil];
    
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    self.systemMessageArray = nil;
    self.headerView = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightItemTouched:(id)sender
{
    //清空消息：：
    [_systemMessageArray removeAllObjects];
    self.tableView.tableHeaderView = _headerView;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.scrollEnabled = NO;
    
    [self.tableView reloadData];
    
    NSMutableDictionary *messageDataBase;
    NSString *messageDataBasePath = [[FileManage documentsPath] stringByAppendingPathComponent:@"MessageDataBase.chat"];
    NSData *messageData = [NSData dataWithContentsOfFile:messageDataBasePath];
    if (messageData != NULL) {
        messageDataBase = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
    } else {
        messageDataBase = [NSMutableDictionary dictionary];
    }
    
    NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:
                                       [messageDataBase objectForKey:@"XTXX"]];
    _systemMessageArray = [NSMutableArray arrayWithArray:[messageDic objectForKey:@"readedMessage"]];
    NSMutableArray *unreadedMessageArray = [NSMutableArray arrayWithArray:[[messageDataBase objectForKey:@"XTXX"] objectForKey:@"unreadedMessage"]];
    if (unreadedMessageArray.count > 0) {
        
        for (XMPPMessage *tempMessage in unreadedMessageArray) {
            [_systemMessageArray addObject:tempMessage];
        }
    }
    
    [unreadedMessageArray removeAllObjects];
    [messageDic setValue:_systemMessageArray forKey:@"readedMessage"];
    [messageDic setValue:unreadedMessageArray forKey:@"unreadedMessage"];
    [messageDataBase setValue:messageDic forKey:@"XTXX"];
    
    messageData = [NSKeyedArchiver archivedDataWithRootObject:messageDataBase];
    [[FileManage fileManage] writeData:messageData toFile:messageDataBasePath];
    postNotification(wlhyUpdateBadgeNumberNotification, nil);
    
}

#pragma mark - XMPP SET

- (void)setXmppStream
{
    
    if (!_wlhyXmpp) {
        _wlhyXmpp = [WlhyXMPP WlhyXMPP];
    }
    [_wlhyXmpp connect];
    [_wlhyXmpp setDelegate:self];
    
    NSMutableDictionary *messageDataBase;
    NSString *messageDataBasePath = [[FileManage documentsPath] stringByAppendingPathComponent:@"MessageDataBase.chat"];
    NSData *messageData = [NSData dataWithContentsOfFile:messageDataBasePath];
    if (messageData != NULL) {
        messageDataBase = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
    } else {
        messageDataBase = [NSMutableDictionary dictionary];
    }
    
    NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:
                                       [messageDataBase objectForKey:@"XTXX"]];
    _systemMessageArray = [NSMutableArray arrayWithArray:[messageDic objectForKey:@"readedMessage"]];
    NSMutableArray *unreadedMessageArray = [NSMutableArray arrayWithArray:[[messageDataBase objectForKey:@"XTXX"] objectForKey:@"unreadedMessage"]];
    if (unreadedMessageArray.count > 0) {
        
        for (XMPPMessage *tempMessage in unreadedMessageArray) {
            [_systemMessageArray addObject:tempMessage];
        }
    }
    
    [unreadedMessageArray removeAllObjects];
    [messageDic setValue:_systemMessageArray forKey:@"readedMessage"];
    [messageDic setValue:unreadedMessageArray forKey:@"unreadedMessage"];
    [messageDataBase setValue:messageDic forKey:@"XTXX"];
    
    messageData = [NSKeyedArchiver archivedDataWithRootObject:messageDataBase];
    [[FileManage fileManage] writeData:messageData toFile:messageDataBasePath];
    postNotification(wlhyUpdateBadgeNumberNotification, nil);
    
    if (_systemMessageArray.count <= 0) {
        self.tableView.tableHeaderView = _headerView;
        self.tableView.separatorColor = [UIColor clearColor];
        self.tableView.scrollEnabled = NO;
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.separatorColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.08];
        self.tableView.scrollEnabled = YES;
    }
    [self.tableView reloadData];
    isReadedMessage = YES;
    
}

#pragma mark - WlhyXmpp Delegate

- (void)XMPPDidConnected
{
    
}
- (void)XMPPDidAuthenticate
{
    
}
- (void)XMPPMessageDidSend:(XMPPMessage *)message
{
    
}

- (void)XMPPMessageDidReceive:(XMPPMessage *)message
{
    NSLog(@"XMPPMessageDidReceive :: %@", message);
    
    /*
     <message xmlns="jabber:client" id="KT982-56" to="12345678957@218.245.5.76" from="18005313926@218.245.5.76/PtaAndroidClient" type="chat"><subject>JSSJ</subject><body>考虑</body><thread>l0Qnq37</thread></message>
     */
    
    /*
     <message xmlns="jabber:client" id="KT982-59" to="12345678957@218.245.5.76" from="18005313926@218.245.5.76/PtaAndroidClient" type="chat"><body>mark_online_会员在线</body><thread>l0Qnq38</thread></message>
     */
    
    /*
     系统消息：：
     <message xmlns="jabber:client" id="Ugt6i-4" to="13466654373@218.245.5.76" from="messageprovider@218.245.5.76/&#x540E;&#x53F0;&#x63A8;&#x9001;" type="chat"><body>{"type":3,"msg":"祝您\347\224\237日快乐","time":"2013-09-24 13:30:16"}</body><thread>D6lIU0</thread></message>
     */

    
    NSString *from = [message fromStr];
    
    NSMutableDictionary *messageDataBase;
    NSString *messageDataBasePath = [[FileManage documentsPath] stringByAppendingPathComponent:@"MessageDataBase.chat"];
    NSData *messageData = [NSData dataWithContentsOfFile:messageDataBasePath];
    if (messageData != NULL) {
        messageDataBase = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
    } else {
        messageDataBase = [NSMutableDictionary dictionary];
    }
    
    if ([from hasPrefix:@"messageprovider"]) {
        //系统消息：：
        [_systemMessageArray addObject:message];
        [self.tableView reloadData];
        
        NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:
                                           [messageDataBase objectForKey:@"XTXX"]];
        NSMutableArray *messageArray = [NSMutableArray arrayWithArray:[messageDic objectForKey:@"readedMessage"]];
        [messageArray addObject:message];
        [messageDic setValue:messageArray forKey:@"readedMessage"];
        [messageDataBase setValue:messageDic forKey:@"XTXX"];
    } else if ([message elementForName:@"subject"]) {
        //前台或私教的消息：：
        [_wlhyXmpp playMessageSound];
        
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


#pragma mark - TableView Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _systemMessageArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    NSDictionary *messageDic = JSONObjectFromString([[[_systemMessageArray objectAtIndex:row] elementForName:@"body"] stringValue]);
    NSLog(@"%@", messageDic);
    
    /*
     系统消息：：
     <message xmlns="jabber:client" id="Ugt6i-4" to="13466654373@218.245.5.76" from="messageprovider@218.245.5.76/&#x540E;&#x53F0;&#x63A8;&#x9001;" type="chat"><body>{"type":3,"msg":"祝您\347\224\237日快乐","time":"2013-09-24 13:30:16"}</body><thread>D6lIU0</thread></message>
     */
    
    WlhySystemMessageCell *cell = (WlhySystemMessageCell *)[tableView dequeueReusableCellWithIdentifier:@"WlhySystemMessageCell"];
    
    if (!cell) {
        cell = [[WlhySystemMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WlhySystemMessageCell"];
    }
    
    cell.messageContentLabel.numberOfLines = 0;
    NSString *contentString = [messageDic objectForKey:@"msg"];
    CGSize autoSize = [contentString sizeWithFont:[UIFont systemFontOfSize:13.0f]
                            constrainedToSize:CGSizeMake(cell.messageContentLabel.frame.size.width, 200.0)
                                lineBreakMode:UILineBreakModeWordWrap];
    cell.messageContentLabel.frame = CGRectMake(20, 5,
                                           cell.messageContentLabel.frame.size.width, autoSize.height);
    
    cell.messageContentLabel.text = contentString;
    cell.messageTimeLabel.text = [messageDic objectForKey:@"time"];
    cell.messageTimeLabel.frame = CGRectMake(cell.messageTimeLabel.frame.origin.x, 5+autoSize.height+5,
                                             cell.messageTimeLabel.frame.size.width, cell.messageTimeLabel.frame.size.height);
    
    cell.cellBGImageView.frame = CGRectMake(0, 0, 320, autoSize.height+30);
    
    cell.frame = CGRectMake(0, 0, 320, autoSize.height+30);
    
    return cell;
}



@end
