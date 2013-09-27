//
//  WlhyWaiterServiceViewController.m
//  wlhybdc
//
//  Created by ios on 13-7-11.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyWaiterServiceViewController.h"

#import "WlhyXMPP.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "UIBubbleTableView.h"
#import "FileManage.h"
#import "FaceToolBar.h"
#import "CommentTrainView.h"


@interface WlhyWaiterServiceViewController ()<UIBubbleTableViewDataSource, WlhyXMPPDelegate, FaceToolBarDelegate, CommentTrainViewDelegate, UIActionSheetDelegate>
{
    BOOL isMessageSended;
    BOOL isMessageRecieved;
}

@property (strong, nonatomic) IBOutlet UIBubbleTableView *chatView;

@property(strong, nonatomic) NSMutableArray *chartDataSource;
@property(strong, nonatomic) WlhyXMPP *wlhyXmpp;
@property(strong, nonatomic) NSString *waiterAccount;
@property(strong, nonatomic) NSString *waiterServerName;
@property(strong, nonatomic) NSString *hostName;
@property(strong, nonatomic) NSString *hostPort;
@property(strong, nonatomic) FaceToolBar *inputBar;
@property (strong, nonatomic) CommentTrainView *commentTrainView;

@property(strong, nonatomic) IBOutlet UIView *waiterInfoView;
@property(strong, nonatomic) IBOutlet UILabel *waiterNameLabel;
@property(strong, nonatomic) IBOutlet UIImageView *waiterImageView;
@property(strong, nonatomic) IBOutlet UILabel *waiterStatusLabel;
@property (strong, nonatomic) IBOutlet UIButton *mobileTelButtton;
@property(strong, nonatomic) IBOutlet UILabel *waiterFromLabel;
@property(strong, nonatomic) IBOutlet UILabel *waiterIntroLabel;


- (IBAction)cancelInput:(id)sender;
- (IBAction)telButtonTapped:(id)sender;


@end

@implementation WlhyWaiterServiceViewController


#pragma mark - VC life

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"前台接待";
    
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
    
    //底部输入框：：
    _inputBar = [[FaceToolBar alloc] initWithFrame:CGRectMake(0.0f,self.view.frame.size.height - toolBarHeight,self.view.frame.size.width,toolBarHeight) superView:self.view];
    _inputBar.delegate=self;
    [self.view addSubview:_inputBar];
    
    _waiterInfoView.layer.cornerRadius = 5;
    _waiterInfoView.layer.borderWidth = 1;
    _waiterInfoView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;
    _waiterInfoView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.75];
    
    self.chatView.bubbleDataSource=self;
    if(!_chartDataSource){
        _chartDataSource = [NSMutableArray array];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isFromVisitorVC) {
        //游客登录：：
        
        [self sendRequest:
         
         @{
         @"memberId": @"",
         @"pwd": @"",
         @"iemi": [OpenUDID value],
         @"phoneType": @""
         }
         
                   action:wlGetFrontDeskInfo
            baseUrlString:wlServer];
        
    } else {
        [self sendRequest:
         
         @{
         @"memberId": [DBM dbm].currentUsers.memberId,
         @"pwd": [DBM dbm].currentUsers.pwd,
         @"iemi": [OpenUDID value],
         @"phoneType": GetOSName()
         }
         
                   action:wlGetFrontDeskInfo
            baseUrlString:wlServer];
    }
    

    
}

-(void)viewDidDisappear:(BOOL)animated
{
    _wlhyXmpp.delegate = nil;
    
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    
    self.chatView = nil;
    self.chartDataSource = nil;
    self.wlhyXmpp = nil;
    self.waiterAccount = nil;
    self.waiterServerName = nil;
    self.hostName = nil;
    self.hostPort = nil;
    self.waiterInfoView = nil;
    self.waiterNameLabel = nil;
    self.waiterImageView = nil;
    self.waiterStatusLabel = nil;
    self.waiterFromLabel = nil;
    self.waiterIntroLabel = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender
{
    if (isMessageSended && isMessageRecieved) {
        [self showCommentView];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)backHome:(id)sender
{
    [_commentTrainView removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showCommentView
{
    _inputBar.userInteractionEnabled = NO;
    _chatView.userInteractionEnabled = NO;
    
    //评论私教
    
    if (!_commentTrainView) {
        _commentTrainView = [[CommentTrainView alloc] initWithFrame:self.view.frame];
        _commentTrainView.delegate = self;
    }
    
    if (![self.view.subviews containsObject:_commentTrainView]) {
        [self.view addSubview:_commentTrainView];
    }
}


#pragma mark - net response

-(void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@---%@",info,error);
    
    if(info) {
        if([[info objectForKey:@"errorCode"] integerValue] == 0) {
            
            //获取前台信息成功：：
            
            /*
             {"imUrl":"218.249.196.106","imPort":"5222","imServerName":"eayun-ef5e6c21c","userName":"前台接待","account":"qt_006","picture":"http://218.249.196.106:8080/bdcServer/img/ems.JPG","errorCode":0,"errorDesc":"获取前台接待人员信息成功"}
            */
            
            _waiterNameLabel.text = [info objectForKey:@"userName"];
            _waiterStatusLabel.text = @"在线";
            _waiterFromLabel.text = [info objectForKey:@"deptname"];
            _waiterIntroLabel.text = [info objectForKey:@"remark"];
            __block WlhyWaiterServiceViewController *this = self;
            NSString *picString = [info objectForKey:@"picture"];
            [_waiterImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:picString]] placeholderImage:[UIImage imageNamed:picString] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [this.waiterImageView setImage:image];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [this.waiterImageView setImage:[UIImage imageNamed:@"default_qt.png"]];
            }];
            
            
            _hostName = [info objectForKey:@"imUrl"];
            _hostPort = [info objectForKey:@"imPort"];
            _waiterAccount = [info objectForKey:@"account"];
            _waiterServerName = [info objectForKey:@"imServerName"];
            
        } else if([[info objectForKey:@"errorCode"] integerValue] == 2) {
            //前台繁忙：：
            
            /*
             {
             errorCode = 2;
             errorDesc = "\U524d\U53f0\U63a5\U5f85\U5750\U5e2d\U5168\U5fd9,\U8bf7\U7a0d\U540e";
             imPort = 5222;
             imServerName = "218.245.5.76";
             imUrl = "218.245.5.76";
             }---(null)
             */
            
            _waiterNameLabel.text = @"前台服务";
            _waiterStatusLabel.text = @"离线";
            _waiterStatusLabel.textColor = [UIColor colorWithRed:0.9 green:0.4 blue:0.4 alpha:1.0];
            _waiterFromLabel.text = @"客户服务部";
            _waiterIntroLabel.text = @"可接受离线消息";
            [_waiterImageView setImage:[UIImage imageNamed:@"default_qt.png"]];
            
            _hostName = [info objectForKey:@"imUrl"];
            _hostPort = [info objectForKey:@"imPort"];
            _waiterAccount = [info objectForKey:@"account"];
            _waiterServerName = [info objectForKey:@"imServerName"];
            
        }
        
        [self setXmppStream];
        
    } else {
        [self showText:@"连接服务器失败！"];
    }
    
}

#pragma mark - XMPP Setting

- (void)setXmppStream
{
    
    if (!_wlhyXmpp) {
        _wlhyXmpp = [WlhyXMPP WlhyXMPP];
    }
    [_wlhyXmpp connect];
    [_wlhyXmpp setDelegate:self];
    [_wlhyXmpp setMate:_waiterAccount serverName:_waiterServerName];
    
    NSMutableDictionary *messageDataBase;
    NSString *messageDataBasePath = [[FileManage documentsPath] stringByAppendingPathComponent:@"MessageDataBase.chat"];
    NSData *messageData = [NSData dataWithContentsOfFile:messageDataBasePath];
    if (messageData != NULL) {
        messageDataBase = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
    } else {
        messageDataBase = [NSMutableDictionary dictionary];
    }
    
    NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:
                                       [messageDataBase objectForKey:@"QTJD"]];
    NSMutableArray *messageArray = [NSMutableArray arrayWithArray:[messageDic objectForKey:@"readedMessage"]];
    
    NSMutableArray *unreadedMessageArray = [NSMutableArray arrayWithArray:[[messageDataBase objectForKey:@"QTJD"] objectForKey:@"unreadedMessage"]];
    if (unreadedMessageArray.count > 0) {
        
        for (XMPPMessage *tempMessage in unreadedMessageArray) {
            NSString *contentString = [[tempMessage elementForName:@"body"] stringValue];
            _chatView.typingBubble = NSBubbleTypingTypeNobody;
            NSBubbleData *sayBubble = [NSBubbleData
                                       dataWithText:contentString
                                       date:[NSDate dateWithTimeIntervalSinceNow:0]
                                       type:BubbleTypeSomeoneElse];
            [_chartDataSource addObject:sayBubble];
            [messageArray addObject:tempMessage];
        }
        [_chatView reloadData];
        
    }
    
    [unreadedMessageArray removeAllObjects];
    [messageDic setValue:messageArray forKey:@"readedMessage"];
    [messageDic setValue:unreadedMessageArray forKey:@"unreadedMessage"];
    [messageDataBase setValue:messageDic forKey:@"QTJD"];
    
    messageData = [NSKeyedArchiver archivedDataWithRootObject:messageDataBase];
    [[FileManage fileManage] writeData:messageData toFile:messageDataBasePath];
    postNotification(wlhyUpdateBadgeNumberNotification, nil);
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
    
    isMessageSended = YES;
    /*
     <message type="chat" to="12345678912@ay12120201181102f7573"><body>hjbjj</body></message>
     */
    
    /*
     <message xmlns="jabber:client" id="KT982-59" to="12345678957@218.245.5.76" from="18005313926@218.245.5.76/PtaAndroidClient" type="chat"><body>mark_online_会员在线</body><thread>l0Qnq38</thread></message>
     */
    
    NSString * str = [[message elementForName:@"body"] stringValue];
    
    _chatView.typingBubble = NSBubbleTypingTypeNobody;
    
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:str date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    [_chartDataSource addObject:sayBubble];
    [_chatView reloadData];

}

- (void)XMPPMessageDidReceive:(XMPPMessage *)message
{
    isMessageRecieved = YES;
    
    /*
     <message xmlns="jabber:client" id="KT982-56" to="12345678957@218.245.5.76" from="18005313926@218.245.5.76/PtaAndroidClient" type="chat"><subject>JSSJ</subject><body>考虑</body><thread>l0Qnq37</thread></message>
     */
    
    /*
     <message xmlns="jabber:client" id="KT982-59" to="12345678957@218.245.5.76" from="18005313926@218.245.5.76/PtaAndroidClient" type="chat"><body>mark_online_会员在线</body><thread>l0Qnq38</thread></message>
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
        [_wlhyXmpp playMessageSound];
        
        NSDictionary *messageDic = [messageDataBase objectForKey:@"XTXX"];
        NSMutableArray *messageArray = [messageDic objectForKey:@"unreadedMessage"];
        [messageArray addObject:message];
        [messageDic setValue:messageArray forKey:@"unreadedMessage"];
        [messageDataBase setValue:messageDic forKey:@"XTXX"];
    } else if ([message elementForName:@"subject"]) {
        //前台或私教的消息：：
        NSString *fromFlag = [[message elementForName:@"subject"] stringValue];
        if ([fromFlag isEqualToString:@"JSSJ"]) {
            //来自【私教】：：
            [_wlhyXmpp playMessageSound];
            
            NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:
                                               [messageDataBase objectForKey:@"JSSJ"]];
            NSMutableArray *messageArray = [NSMutableArray arrayWithArray:[messageDic objectForKey:@"unreadedMessage"]];
            [messageArray addObject:message];
            [messageDic setValue:messageArray forKey:@"unreadedMessage"];
            [messageDataBase setValue:messageDic forKey:@"JSSJ"];
        } else if ([fromFlag isEqualToString:@"QTJD"]) {
            //来自【前台】：：
            NSString *contentString = [[message elementForName:@"body"] stringValue];
            _chatView.typingBubble = NSBubbleTypingTypeNobody;
            NSBubbleData *sayBubble = [NSBubbleData
                                       dataWithText:contentString
                                       date:[NSDate dateWithTimeIntervalSinceNow:0]
                                       type:BubbleTypeSomeoneElse];
            [_chartDataSource addObject:sayBubble];
            [_chatView reloadData];
            
            
            NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:
                                               [messageDataBase objectForKey:@"QTJD"]];
            NSMutableArray *messageArray = [NSMutableArray arrayWithArray:[messageDic objectForKey:@"readedMessage"]];
            [messageArray addObject:message];
            [messageDic setValue:messageArray forKey:@"readedMessage"];
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


#pragma mark - UIBubbleTableViewDataSource
-(NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return _chartDataSource.count;
}
-(NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row{
    return _chartDataSource[row];
}

- (IBAction)cancelInput:(id)sender
{
    [_inputBar resignFirstResponder];
    [_inputBar dismissKeyBoard];
}

#pragma mark - FaceToolBarDelegate

-(void)sendTextAction:(NSString *)inputText
{
    //发送消息
    [_wlhyXmpp sendMessage:inputText];
}

- (void)finishCommentList:(NSInteger)index content:(NSString *)contentString
{
    /*
     memberid
     account
     pwd
     result
     content
     servicetype     1：前台接待 2：私教
     */
    
    
    [self sendRequest:
     
     @{
     @"memberid": [DBM dbm].currentUsers.memberId,
     @"pwd": [DBM dbm].currentUsers.pwd,
     @"account": _waiterAccount,
     @"result": [NSNumber numberWithInt:index],
     @"content": contentString,
     @"servicetype": @"1"
     }
     
               action:wlCommentServerPersonRequest
        baseUrlString:wlServer];
}

#pragma mark - Tel Handler

- (IBAction)telButtonTapped:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    
    int tag = btn.tag;
    
    if (tag == 1400) {
        //手机号码按钮：：
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:[NSString stringWithFormat:@"联系 %@", btn.currentTitle]
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"呼叫", nil];
        [actionSheet showInView:self.view];
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        [self callPhone:@"010-67052922"];
    }
    
}

- (void)callPhone:(NSString *)phoneNumber
{
    NSString *callTelString = [NSString stringWithFormat:@"tel://%@", phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callTelString]];
}

- (void)sendMessageToPhone:(NSString *)phoneNumber
{
    NSString *callTelString = [NSString stringWithFormat:@"sms://%@", phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callTelString]];
}


@end
