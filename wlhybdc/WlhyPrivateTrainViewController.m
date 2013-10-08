//
//  WlhyPrivateTrainViewController.m
//  wlhybdc
//
//  Created by ios on 13-7-15.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyPrivateTrainViewController.h"

#import "WlhyXMPP.h"

#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "FaceToolBar.h"
#import "FileManage.h"
#import "CommentTrainView.h"

@interface WlhyPrivateTrainViewController () <UIBubbleTableViewDataSource, FaceToolBarDelegate, WlhyXMPPDelegate, CommentTrainViewDelegate, UIActionSheetDelegate>
{
    BOOL isMessageSended;
    BOOL isMessageRecieved;
}

@property (strong, nonatomic) NSMutableArray* chartDataSource;
@property(strong, nonatomic) NSDictionary *trainInfo;

@property (strong, nonatomic) NSString *trainAccount;
@property (strong, nonatomic) NSString *trainServerName;

@property(strong, nonatomic) WlhyXMPP *wlhyXmpp;
@property (strong, nonatomic) IBOutlet UIBubbleTableView *chatBubbleTableView;

@property (strong, nonatomic) IBOutlet UIView *trainInfoView;
@property (strong, nonatomic) CommentTrainView *commentTrainView;

@property(strong, nonatomic) FaceToolBar *inputBar;

@property (strong, nonatomic) IBOutlet UIImageView *trainImageView;
@property (strong, nonatomic) IBOutlet UILabel *trainStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *trainNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *mobileTelButtton;
@property (strong, nonatomic) IBOutlet UILabel *trainTelLabel;
@property (strong, nonatomic) IBOutlet UILabel *trainClubLabel;
@property (strong, nonatomic) IBOutlet UILabel *trainWorkTimeLabel;



- (IBAction)changeTrainButton:(id)sender;
- (IBAction)cancelInput:(id)sender;
- (IBAction)telButtonTapped:(id)sender;


@end

//--------------------------------------------------------------------------

@implementation WlhyPrivateTrainViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - VC life

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"健身私教";
    
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
    
    //右侧按钮：：
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setContentMode:UIViewContentModeScaleToFill];
    [rightButton setTitle:@"详情" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_0.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_1.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(self.view.frame.size.width - 70, 0, 66, 40);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //底部输入框：：
    _inputBar = [[FaceToolBar alloc] initWithFrame:CGRectMake(0.0f,self.view.frame.size.height - toolBarHeight,self.view.frame.size.width,toolBarHeight) superView:self.view];
    _inputBar.delegate=self;
    [self.view addSubview:_inputBar];
    
    
    _trainInfoView.layer.cornerRadius = 7;
    _trainInfoView.layer.borderWidth = 1;
    _trainInfoView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;
    _trainInfoView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.75];

    _chatBubbleTableView.bubbleDataSource=self;
    if(!_chartDataSource){
        _chartDataSource = [NSMutableArray array];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    if (!_trainInfo) {
        [self sendRequest:
         
         @{@"memberId":[DBM dbm].currentUsers.memberId,
         @"pwd":[DBM dbm].currentUsers.pwd,
         @"servicePersonId": [DBM dbm].usersExt.servicePersonId}
         
                   action:wlGetTrainInfoRequest
            baseUrlString:wlServer];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    _wlhyXmpp.delegate = nil;
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.inputBar.delegate = nil;
        
        self.chartDataSource = nil;
        self.trainInfo = nil;
        self.trainAccount = nil;
        self.trainServerName = nil;
        self.wlhyXmpp = nil;
        self.chatBubbleTableView = nil;
        self.trainInfoView = nil;
        self.inputBar = nil;
        self.trainImageView = nil;
        self.trainStatusLabel = nil;
        self.trainNameLabel = nil;
        self.trainTelLabel = nil;
        self.trainClubLabel = nil;
        self.trainWorkTimeLabel = nil;
        self.commentTrainView = nil;
        self.mobileTelButtton = nil;
    }
}

- (void)back:(id)sender
{
    if (isMessageSended && isMessageRecieved) {
        [self showCommentView];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)backHome:(id)sender
{
    [_commentTrainView removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)rightItemTouched:(id)sender
{
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyTrainDetailViewController"];
    if ([destVC respondsToSelector:@selector(setTrainInfo:)]) {
        [destVC setValue:_trainInfo forKey:@"trainInfo"];
    }
    [self.navigationController pushViewController:destVC animated:YES];
}

#pragma mark - processRequest

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@---%@",info,error);
    
    if ([action isEqualToString:wlCommentServerPersonRequest]) {
        if (info) {
            if([[info objectForKey:@"errorCode"] integerValue] == 0) {
                [self showText:@"评价成功"];
                [self performSelector:@selector(backHome:) withObject:nil afterDelay:1.5f];
            } else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
        } else {
            [self showText:@"连接服务器失败！"];
        }
    }
    
    if ([action isEqualToString:wlGetTrainInfoRequest]) {
        if(info){
            if([[info objectForKey:@"errorCode"] integerValue] == 0){
                
                /*
                 {
                 account = 18005313926;
                 activity = 0;
                 age = 20;
                 blog = "\U6167\U52a8\U5065\U8eab";
                 channel = "\U6167\U52a8\U5065\U8eab";
                 deptName = "wangm\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
                 deptid = 001003015;
                 eMail = "Hdjs@huidong.com";
                 educational = 4;
                 errorCode = 0;
                 errorDesc = "\U67e5\U8be2\U5065\U8eab\U79c1\U6559\U8be6\U7ec6\U4fe1\U606f\U6210\U529f";
                 experience = "\U4ece\U4e8b\U5065\U8eab\U79c1\U6559\U5de5\U4f5c\U4e09\U5e74";
                 honor = "\U88ab\U8bc4\U4e3a\U4f18\U79c0\U5065\U8eab\U6559\U7ec3";
                 integral = 0;
                 introduction = "\U70ed\U7231\U5065\U8eab\U79c1\U6559\U5de5\U4f5c";
                 isonline = "\U5728\U7ebf";
                 level = 2;
                 nickname = "\U79c1\U6559\U5f3a";
                 picture = "http://www.holddo.com:80/bdcServer/img/personaltrainer/18005313926.jpg";
                 remark = "\U70ed\U7231\U5065\U8eab\U79c1\U6559\U5de5\U4f5c";
                 sex = 1;
                 specialSkill = 4;
                 userName = "\U738b\U5f3a";
                 userQQ = 18005313926;
                 userStaticTel = "";
                 userTel = 18005313926;
                 userType = 41;
                 worktime = "8:00-17:00";
                 }
                 */
                
                _trainInfo = info;
                _trainAccount = [info objectForKey:@"account"];
                _trainServerName = [DBM dbm].currentUsers.imServerName;
                [self setXmppStream];
                [self setUI:info];
                
            }else if([[info objectForKey:@"errorCode"] integerValue] == 2){
                //未查询到私教：：
                [self showText:@"未查询到您的健身私教"];
            }
        }else{
            [self showText:@"连接服务器失败！"];
        }
    }
    
}

#pragma mark - _xmppStream set

- (void)setUI:(NSDictionary *)info
{
    /*
     {
     account = 18005313926;
     deptName = "wangm\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
     deptid = 001003015;
     eMail = "Hdjs@huidong.com";
     errorCode = 0;
     errorDesc = "\U67e5\U8be2\U5065\U8eab\U79c1\U6559\U8be6\U7ec6\U4fe1\U606f\U6210\U529f";
     isonline = "\U5728\U7ebf";
     picture = "http://www.holddo.com:80/bdcServer/img18005313926.jpg";
     remark = "\U70ed\U7231\U5065\U8eab\U79c1\U6559\U5de5\U4f5c";
     sex = 2;
     specialSkill = 4;
     userName = "\U738b\U5f3a";
     userQQ = 18005313926;
     userStaticTel = "";
     userTel = 18005313926;
     userType = 41;
     worktime = "8:00-17:00";
     }
     */
    
    __block WlhyPrivateTrainViewController *this = self;
    NSString *picString = [info objectForKey:@"picture"];
    
    [self.trainImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:picString]] placeholderImage:[UIImage imageNamed:picString] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [this.trainImageView setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if ([[info objectForKey:@"sex"] intValue] == 0) {
            [this.trainImageView setImage:[UIImage imageNamed:@"head_f.png"]];
        } else {
            [this.trainImageView setImage:[UIImage imageNamed:@"head_sj.png"]];
        }
    }];
    
    _trainNameLabel.text = [info objectForKey:@"userName"];
    _trainTelLabel.text = ([[info objectForKey:@"userStaticTel"] isEqualToString:@""]) ? @"暂无" : [info objectForKey:@"userStaticTel"];
    _trainClubLabel.text = [info objectForKey:@"deptName"];
    _trainWorkTimeLabel.text = [info objectForKey:@"worktime"];
    
    [_mobileTelButtton setTitle:[_trainInfo objectForKey:@"userTel"] forState:UIControlStateNormal];
    [_mobileTelButtton setTitle:[_trainInfo objectForKey:@"userTel"] forState:UIControlStateHighlighted];
    
    _trainStatusLabel.text = [info objectForKey:@"isonline"];
    if ([_trainStatusLabel.text isEqualToString:@"离线"]) {
        _trainStatusLabel.textColor = [UIColor colorWithRed:0.9 green:0.4 blue:0.4 alpha:1.0];
    }
    
    [DBM dbm].usersExt.serviceName = [info objectForKey:@"userName"];
    
}

#pragma mark - XMPP SET

- (void)setXmppStream
{
    
    if (!_wlhyXmpp) {
        _wlhyXmpp = [WlhyXMPP WlhyXMPP];
    }
    [_wlhyXmpp connect];
    [_wlhyXmpp setDelegate:self];
    NSLog(@"%@ , %@", _trainAccount, _trainServerName);
    [_wlhyXmpp setMate:_trainAccount serverName:_trainServerName];
    
    NSMutableDictionary *messageDataBase;
    NSString *messageDataBasePath = [[FileManage documentsPath] stringByAppendingPathComponent:@"MessageDataBase.chat"];
    NSData *messageData = [NSData dataWithContentsOfFile:messageDataBasePath];
    if (messageData != NULL) {
        messageDataBase = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
    } else {
        messageDataBase = [NSMutableDictionary dictionary];
    }
    
    NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:
                                       [messageDataBase objectForKey:@"JSSJ"]];
    NSMutableArray *messageArray = [NSMutableArray arrayWithArray:[messageDic objectForKey:@"readedMessage"]];
    
    NSMutableArray *unreadedMessageArray = [NSMutableArray arrayWithArray:[[messageDataBase objectForKey:@"JSSJ"] objectForKey:@"unreadedMessage"]];
    if (unreadedMessageArray.count > 0) {
        
        for (XMPPMessage *tempMessage in unreadedMessageArray) {
            NSString *contentString = [[tempMessage elementForName:@"body"] stringValue];
            _chatBubbleTableView.typingBubble = NSBubbleTypingTypeNobody;
            NSBubbleData *sayBubble = [NSBubbleData
                                       dataWithText:contentString
                                       date:[NSDate dateWithTimeIntervalSinceNow:0]
                                       type:BubbleTypeSomeoneElse];
            [_chartDataSource addObject:sayBubble];
            [messageArray addObject:tempMessage];
        }
        [_chatBubbleTableView reloadData];
        
    }
    
    [unreadedMessageArray removeAllObjects];
    [messageDic setValue:messageArray forKey:@"readedMessage"];
    [messageDic setValue:unreadedMessageArray forKey:@"unreadedMessage"];
    [messageDataBase setValue:messageDic forKey:@"JSSJ"];
    
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
    
    _chatBubbleTableView.typingBubble = NSBubbleTypingTypeNobody;
    
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:str date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    [_chartDataSource addObject:sayBubble];
    [_chatBubbleTableView reloadData];
    
    [_inputBar resignFirstResponder];
    [_inputBar dismissKeyBoard];
    
}
- (void)XMPPMessageDidReceive:(XMPPMessage *)message
{
    NSLog(@"XMPPMessageDidReceive :: %@", message);
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
            
            NSString *contentString = [[message elementForName:@"body"] stringValue];
            _chatBubbleTableView.typingBubble = NSBubbleTypingTypeNobody;
            NSBubbleData *sayBubble = [NSBubbleData
                                       dataWithText:contentString
                                       date:[NSDate dateWithTimeIntervalSinceNow:0]
                                       type:BubbleTypeSomeoneElse];
            [_chartDataSource addObject:sayBubble];
            [_chatBubbleTableView reloadData];

            NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:
                                               [messageDataBase objectForKey:@"JSSJ"]];
            NSMutableArray *messageArray = [NSMutableArray arrayWithArray:[messageDic objectForKey:@"readedMessage"]];
            [messageArray addObject:message];
            [messageDic setValue:messageArray forKey:@"readedMessage"];
            [messageDataBase setValue:messageDic forKey:@"JSSJ"];
        } else if ([fromFlag isEqualToString:@"QTJD"]) {
            //来自【前台】：：
            [_wlhyXmpp playMessageSound];
            
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


#pragma mark - button Handler

- (IBAction)changeTrainButton:(id)sender
{
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyRechargeViewController"];
    if ([destVC respondsToSelector:@selector(setRechargeVCPurpose:)]) {
        [destVC setValue:[NSNumber numberWithInt:1] forKey:@"rechargeVCPurpose"];
        [self.navigationController pushViewController:destVC animated:YES];
    }
}


- (void)showCommentView
{
    _inputBar.userInteractionEnabled = NO;
    _chatBubbleTableView.userInteractionEnabled = NO;
    
    //评论私教
    
    if (!_commentTrainView) {
        _commentTrainView = [[CommentTrainView alloc] initWithFrame:self.view.frame];
        _commentTrainView.delegate = self;
    }
    
    if (![self.view.subviews containsObject:_commentTrainView]) {
        [self.view addSubview:_commentTrainView];
    }
}

- (IBAction)cancelInput:(id)sender
{
    [_inputBar resignFirstResponder];
    [_inputBar dismissKeyBoard];
}

#pragma mark - UIBubbleTableViewDataSource

-(NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return _chartDataSource.count;
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return _chartDataSource[row];
}



#pragma mark - FaceToolBarDelegate

-(void)sendTextAction:(NSString *)inputText
{
    //发送消息
    [_wlhyXmpp sendMessage:inputText];
}

- (void)voiceButtonAction
{
    return;
}

#pragma mark - CommentView Delegate

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
     @"account": _trainAccount,
     @"result": [NSNumber numberWithInt:index],
     @"content": contentString,
     @"servicetype": @"2"
     }
     
               action:wlCommentServerPersonRequest
        baseUrlString:wlServer];
}

#pragma mark - Tel Handler

- (IBAction)telButtonTapped:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    if (![btn.currentTitle hasPrefix:@"1"]) {
        //return;
    }
    int tag = btn.tag;
    
    if (tag == 1400) {
        //手机号码按钮：：
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:[NSString stringWithFormat:@"联系 %@", btn.currentTitle]
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"呼叫",@"发短信", nil];
        [actionSheet showInView:self.view];
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        [self callPhone:[_trainInfo objectForKey:@"userTel"]];
    } else if (buttonIndex == 1) {
        [self sendMessageToPhone:[_trainInfo objectForKey:@"userTel"]];
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
