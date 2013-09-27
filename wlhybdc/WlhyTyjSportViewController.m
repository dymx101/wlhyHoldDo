//
//  WlhyTyjSportViewController.m
//  wlhybdc
//
//  Created by Hello on 13-9-9.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyTyjSportViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"

#import "WlhySportTotalCell.h"
#import "LineChartView.h"
#import "FileManage.h"
#import "WlhyXMPP.h"
#import "SportGuideMessageView.h"
#import "DropButtonView.h"

#define Equip_Command_Request @"/BdrServer/CmdSendApi"
#define Equip_Connect_Request @"/BdrServer/ConnectStateApi"

static CGFloat TimerInterval = 0.5f;

@interface WlhyTyjSportViewController () <IFlySpeechSynthesizerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate, UIAlertViewDelegate, UIActionSheetDelegate, WlhyXMPPDelegate, DropButtonViewDelegate>
{
    float totalDistance;
    float totalTime;
    
    int prepareCount;   //倒计时标记
    
    int currentStep;
    BOOL isStart;
    BOOL isIFlySpeechPlaying;
    BOOL isServerConnected;
    BOOL shouldPlaySystemSound;
    BOOL shouldPlayTrainSound;
    
    float continueTime;        // 单位为秒
}

@property(strong, nonatomic) NSDictionary *dataSource;

@property(strong, nonatomic) IBOutlet UIImageView *animationImageView;
@property(strong, nonatomic) IBOutlet UIImageView *countDownImageView;
@property(strong, nonatomic) IBOutlet UILabel *serverConnectionStateLabel;
@property(strong, nonatomic) IBOutlet UILabel *equipConnectionStateLabel;
@property(strong, nonatomic) IBOutlet UILabel *currentStepLabel;
@property(strong, nonatomic) IBOutlet UILabel *currentSpeedLabel;
@property(strong, nonatomic) IBOutlet UILabel *currentStepTimeLabel;
@property(strong, nonatomic) DropButtonView *dropButtonView;

@property(strong, nonatomic) WlhyXMPP *wlhyXmpp;
@property(strong, nonatomic) IFlySpeechSynthesizer *iFlySpeechSynthesizer;
@property(nonatomic, strong) WlhySportTotalCell *sportCell;
@property(strong, nonatomic) AVAudioPlayer *audioPlayer;
@property(strong, nonatomic) SportGuideMessageView *sportGuideMessageView;

@property(nonatomic,strong) NSString *bdrConnPath;

@property(nonatomic,strong) NSTimer *prepareTImer;
@property(nonatomic,strong) NSTimer *sportRunTimer;
@property(nonatomic,strong) NSDate * startTime;
@property(nonatomic,strong) NSDate * endTime;
@property(nonatomic,strong) NSDate * storeTime;
@property(nonatomic, strong) NSMutableArray *animationImageArray;

@property(nonatomic, strong) IBOutlet LineChartView *runView;


- (IBAction)controllButtonHandler:(id)sender;


@end



@implementation WlhyTyjSportViewController


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if(self){
        shouldPlaySystemSound = YES;
        shouldPlayTrainSound = YES;
    }
    return self;
}


#pragma mark - VC lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"今日运动";
    
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
    [rightButton setTitle:@"设置" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_0.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_1.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(self.view.frame.size.width - 70, 0, 66, 40);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    // 设置语音合成的参数
    NSString *initString = [NSString stringWithFormat:@"appid=%@",iFlyAPPID];
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer createWithParams:initString delegate:self];
    
    [_iFlySpeechSynthesizer setParameter:@"speed" value:@"50"];//合成的语速,取值范围 0~100
    [_iFlySpeechSynthesizer setParameter:@"volume" value:@"50"];//合成的音量;取值范围 0~100
    //发音人,默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表;
    [_iFlySpeechSynthesizer setParameter:@"voice_name" value:@"xiaoyan"];
    [_iFlySpeechSynthesizer setParameter:@"sample_rate" value:@"8000"];//音频采样率,目前支持的采样率有 16000 和 8000;
    
    isStart = NO;
    
    _animationImageArray = [NSMutableArray array];
    for (int i = 1; i < 5; i++) {
        [_animationImageArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"dca0%i.png", i]]];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*
     {
     bdrConnPath = "http://42.121.106.113:8888";
     equipType = 1001;
     errorCode = 0;
     errorDesc = "\U83b7\U5f97\U5904\U65b9\U6210\U529f";
     exeResult = "";
     exerciseGoals = "\U63d0\U9ad8\U5fc3\U80ba\U529f\U80fd";
     generation = 3;
     gifPath = "http://42.121.106.113/bdcServer/img/equip/0003_ZD-2611.gif";
     goalEnergyConsumption = "66.4";
     name = "\U8dd1\U6b65\U673a";
     note = "\U901a\U8fc7\U8dd1\U6b65\U673a\U5c3d\U5fc3\U953b\U70bc\U524d\Uff0c\U8bf7\U68c0\U67e5\U8dd1\U6b65\U673a\U7684\U5b89\U5168\U6027\Uff0c\U6ce8\U610f\U81ea\U5df1\U7684\U8eab\U4f53\U72b6\U51b5\U662f\U5426\U9002\U5408\U5065\U8eab\U3002";
     prescriptionId = "f5c73fb2-f226-4109-8e9d-c7680c99547f";
     prescriptionValue = "\U8dd1\U6b65\U673a\U8fdb\U884c\U89c4\U5f8b\U5730\U5065\U8eab\U53ef\U4ee5\U6709\U6548\U6539\U5584\U7761\U7720\U8d28\U91cf\U3002";
     slopeUnits = "";
     sportPattern = "\U95f4\U6b47\U8fd0\U52a8";
     sportShowType = 1;
     sportSteps =     (
     {
     bigStep = 1;
     contents = "";
     frequency = "";
     resttime = "";
     slope = 3;
     smallStep = 1;
     speed = 3;
     step = "";
     strength = "";
     time = 2;
     title = "";
     },
     {
     bigStep = 1;
     contents = "";
     frequency = "";
     resttime = "";
     slope = 5;
     smallStep = 2;
     speed = 6;
     step = "";
     strength = "";
     time = 2;
     title = "";
     },
     {
     bigStep = 1;
     contents = "";
     frequency = "";
     resttime = "";
     slope = 8;
     smallStep = 3;
     speed = 8;
     step = "";
     strength = "";
     time = 3;
     title = "";
     },
     {
     bigStep = 1;
     contents = "";
     frequency = "";
     resttime = "";
     slope = 6;
     smallStep = 4;
     speed = 6;
     step = "";
     strength = "";
     time = 2;
     title = "";
     },
     {
     bigStep = 1;
     contents = "";
     frequency = "";
     resttime = "";
     slope = 3;
     smallStep = 5;
     speed = 3;
     step = "";
     strength = "";
     time = 2;
     title = "";
     }
     );
     }
     */
    
    //页面出现的时候，根据私教id去请求私教详细信息：：
    if ([_trainID intValue] > 0) {
        [self sendRequest:
         
         @{@"memberId":[DBM dbm].currentUsers.memberId,
         @"pwd":[DBM dbm].currentUsers.pwd,
         @"servicePersonId": _trainID}
         
                   action:wlGetCertainTrainInfoRequest
            baseUrlString:wlServer];
    }
    
    //获取之前保存过得运动数据：：
    [self getSportsData];
    NSLog(@"%@", _dataSource);
    
    [self getConnectStatus];
    
    [_runView setDataSource:[_dataSource objectForKey:@"sportSteps"]];
    
    _serverConnectionStateLabel.text = @"正常";
    _equipConnectionStateLabel.text = @"正常";
    
    _sportCell.durationTime.text = WlhyString([self getFormattedContinueTime:continueTime]);
    _sportCell.durationDistance.text = WlhyString([NSString stringWithFormat:@"%.2fkm", [self getDurationDistanceWithTime:continueTime]]);
    
    
    NSArray *stepArray = [_dataSource objectForKey:@"sportSteps"];
    NSDictionary *stepDic = [stepArray objectAtIndex:currentStep];
    
    _currentStepLabel.text = WlhyString([NSString stringWithFormat:@"第%i阶段", currentStep + 1]);
    _currentSpeedLabel.text = WlhyString([NSString stringWithFormat:@"%@km/h", [stepDic objectForKey:@"speed"]]);
    _currentStepTimeLabel.text = WlhyString([NSString stringWithFormat:@"%@min", [stepDic objectForKey:@"time"]]);
    
    [_runView movePointerWithTime:continueTime/60];
    
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_iFlySpeechSynthesizer stopSpeaking];
    [_iFlySpeechSynthesizer setDelegate:nil];
    _iFlySpeechSynthesizer = nil;
    WL_INVALIDATE_TIMER(_prepareTImer);
    WL_INVALIDATE_TIMER(_sportRunTimer);
    [_wlhyXmpp setDelegate:nil];
    
    [super viewWillDisappear:YES];
}

- (void)viewDidUnload
{
    [_iFlySpeechSynthesizer setDelegate:nil];
    [_sportRunTimer invalidate];
    
    self.barDecode = nil;
    self.prescriptionId = nil;
    
    self.dataSource = nil;
    self.animationImageView = nil;
    self.serverConnectionStateLabel = nil;
    self.equipConnectionStateLabel = nil;
    self.currentStepLabel = nil;
    self.currentSpeedLabel = nil;
    self.currentStepTimeLabel = nil;
    self.dropButtonView = nil;
    
    self.iFlySpeechSynthesizer = nil;
    self.sportCell = nil;
    self.audioPlayer = nil;
    
    self.dropButtonView = nil;
    self.bdrConnPath = nil;
    
    self.prepareTImer = nil;
    self.sportRunTimer = nil;
    self.startTime = nil;
    self.endTime = nil;
    self.storeTime = nil;
    self.animationImageArray = nil;
    self.runView = nil;
    self.sportGuideMessageView = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - navBar handler

- (void)back:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"您确定要结束锻炼吗？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    [alertView show];
    
}

#pragma mark - DropButtonView

- (void)rightItemTouched:(id)sender
{
    NSLog(@"rightItemTouched");
    
    if ([self.view.subviews containsObject:_dropButtonView]) {
        [_dropButtonView removeFromSuperview];
        return;
    }
    
    if (!_dropButtonView) {
        _dropButtonView = [[DropButtonView alloc] initWithFrame:CGRectMake(195, 10, 116, 148)];
        _dropButtonView.delegate = self;
    }
    
    if (![self.view.subviews containsObject:_dropButtonView]) {
        [self.view addSubview:_dropButtonView];
    }
}

#pragma mark - DropButton Delegate

- (void)dropButtonTapped:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    int tag = [btn tag];
    
    if (tag == 1000) {
        if (btn.selected) {
            shouldPlaySystemSound = NO;
        } else {
            shouldPlaySystemSound = YES;
        }
    }
    if (tag == 1001) {
        if (btn.selected) {
            shouldPlayTrainSound = NO;
        } else {
            shouldPlayTrainSound = YES;
        }
    }
    if (tag == 1002) {
        //使用说明书：：
        [self showText:@"功能未开通，敬请期待"];
    }
    if (tag == 1003) {
        //售后服务：：
        [self showText:@"功能未开通，敬请期待"];
    }
    if (tag == 1004) {
        //分享：：
        [self showText:@"功能未开通，敬请期待"];
    }
    
    [_dropButtonView removeFromSuperview];
}


- (void)showActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"您对本次运动感觉如何？"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"很轻松",@"正合适",@"有点累",@"累死了", nil];
    [actionSheet showInView:self.view];
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
            [self handlerTrainMessage:contentString];
            
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
    
}

- (void)handlerTrainMessage:(NSString *)contentString
{
    if (!_sportGuideMessageView) {
        _sportGuideMessageView = [[SportGuideMessageView alloc]
                                  initWithFrame:CGRectMake(0, self.view.bounds.size.height - 100, 320, 100)];
    }
    
    if (![self.tableView.subviews containsObject:_sportGuideMessageView]) {
        
        CATransition *switchAnimation = [CATransition animation];
        switchAnimation.delegate = self;
        switchAnimation.duration = 0.8;
        switchAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
        switchAnimation.type = @"fade";
        switchAnimation.subtype = @"fromTop";
        //@"cube" @"moveIn" @"reveal" @"fade" @"pageCurl" @"pageUnCurl" @"suckEffect" @"rippleEffect" @"oglFlip"
        [self.tableView addSubview:_sportGuideMessageView];
        
        [[_sportGuideMessageView layer] addAnimation:switchAnimation forKey:@"mySwitch"];
        
    }
    [_sportGuideMessageView setMessageContent:contentString];
    
    NSString *TTSString = [NSString stringWithFormat:@"健身私教发来消息：%@", contentString];
    [self IFlySpeakTrainMessage:TTSString];
}

#pragma mark - hand SportsData

- (void)getSportsData
{
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *prescKey = @"";
    
    
    prescKey = [NSString stringWithFormat:@"%@+%@",
                [DBM dbm].currentUsers.memberId, _barDecode];
    
    NSDictionary *d = [userDefaults dictionaryForKey:prescKey];
    _dataSource = [d objectForKey:@"dataSource"];
    
    NSLog(@"_dataSource :: %@", _dataSource);
    
    _bdrConnPath = [_dataSource objectForKey:@"bdrConnPath"];
    
    _prescriptionId = [_dataSource objectForKey:@"prescriptionId"];
    
    NSDictionary *flagInfo = [d objectForKey:@"flagInfo"];
    NSLog(@"flagInfo :: %@", flagInfo);
    
    if (flagInfo != NULL) {
        
        NSLog(@"%@", [flagInfo objectForKey:@"continueTime"]);
        continueTime = [[flagInfo objectForKey:@"continueTime"] floatValue];
        currentStep = [self getCurrentStepWithTime:continueTime];
        BOOL isCompleted = [[flagInfo objectForKey:@"isCompleted"] boolValue];
        
        if (isCompleted) {
            //是上次的运动,并且    已经完成：：
            [self.tableView reloadData];
            
            [self showText:@"您今天已经完成了该处方"];
        }
    }
    
    totalDistance = [self getTotalDistance];
    totalTime = [self getTotalByKey:@"time"];
    
    
    
    NSLog(@"continueTime :: %f", continueTime);
    NSLog(@"totalTime :: %f", totalTime);
    NSLog(@"currentStep :: %i", currentStep);
    
}

- (void)storeSportsData
{
    
    if(!_dataSource || !isStart){
        return;
    }
    
    [self storeTodaySportStatus];
    
    NSString *prescKey = [NSString stringWithFormat:@"%@+%@",
                          [DBM dbm].currentUsers.memberId, _barDecode];
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *flagDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             localNow(), @"storeTime",
                             [NSNumber numberWithBool:[self isSportsCompleted]], @"isCompleted",
                             [NSNumber numberWithFloat:continueTime], @"continueTime" ,
                             _prescriptionId, @"prescriptionId" , nil];
    
    [userDefaults removeObjectForKey:prescKey];
    [userDefaults setObject:
     
     @{@"dataSource":_dataSource,
     @"flagInfo":   flagDic}
     
                     forKey:prescKey];
    
    [userDefaults synchronize];
    
    isStart = NO;
    continueTime = 0;
    
    NSLog(@"prescKey :: %@", prescKey);
    NSLog(@"userDefaults :: %@", [userDefaults dictionaryForKey:prescKey]);
}

- (void)storeTodaySportStatus
{
    int status = 0;
    if (isStart == NO) {
        status = 0;
    } else if (![self isSportsCompleted]) {
        status = 1;
    } else if ([self isSportsCompleted]) {
        status = 2;
    }
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *flagDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:status], @"isOver",
                             localNow(), @"storeTime", nil];
    
    [userDefaults removeObjectForKey:@"TodaySportStatus"];
    [userDefaults setObject:flagDic forKey:@"TodaySportStatus"];
    [userDefaults synchronize];
}

//--------------------------------
#pragma mark - Private functions

- (float)getDurationDistanceWithTime:(float)time
{
    float distance = 0.0;
    float timeOfDoneStep = 0.0;
    
    NSArray *stepArray = [_dataSource objectForKey:@"sportSteps"];
    for (int i = 0; i < currentStep; i++) {
        timeOfDoneStep += [[[stepArray objectAtIndex:i] objectForKey:@"time"] floatValue] * 60;
        distance += [[[stepArray objectAtIndex:i] objectForKey:@"speed"] floatValue] * [[[stepArray objectAtIndex:i] objectForKey:@"time"] floatValue] / 3600;
    }
    
    distance += [[[stepArray objectAtIndex:currentStep] objectForKey:@"speed"] floatValue] * (time - timeOfDoneStep) / 3600;
    return distance;
}

- (NSString *)getFormattedContinueTime:(float)time
{
    //传入的time参数的单位是：秒
    int minute = time / 60;
    int second = time - minute * 60;
    NSString *formattedTime = [NSString stringWithFormat:@"%i:%i", minute, second];
    return formattedTime;
}

//time :: 已经过去的持续时间，单位：秒
- (int)getStepRemainSecondsWithContinueTime:(float)time
{
    NSArray *stepArray = [_dataSource objectForKey:@"sportSteps"];
    float stepEndTime = 0.0;
    
    for (int i = 0; i <= currentStep; i++) {
        NSDictionary *stepInfo = [stepArray objectAtIndex:i];
        stepEndTime += [[stepInfo objectForKey:@"time"] floatValue];
    }
    
    int remainSeconds = stepEndTime * 60 - time;
    return remainSeconds;
}

- (int)getCurrentStepWithTime:(float)time
{
    NSLog(@"time :: %f", time);//分钟
    
    int step = 0;
    float timeSum = 0.0;
    
    NSArray *stepArray = [_dataSource objectForKey:@"sportSteps"];
    for (int i = 0; i < stepArray.count; i++) {
        NSDictionary *stepInfo = [stepArray objectAtIndex:i];
        timeSum += [[stepInfo objectForKey:@"time"] floatValue] * 60;
        if (time <= timeSum) {
            step = i;
            break;
        }
    }
    
    NSLog(@"step :: %i", step);
    return step;
}

- (CGFloat)getTotalByKey:(NSString*)key
{
    CGFloat  total = 0.0f;
    NSArray *tempArray = [_dataSource objectForKey:@"sportSteps"];
    for (NSDictionary *dict in tempArray) {
        total += [[dict objectForKey:key] floatValue];
    }
    
    //如果是时间，则返回的数量的单位为--分钟--：：
    return total;
}

- (CGFloat)getTotalDistance
{
    CGFloat  total = 0.0f;
    NSArray *tempArray = [_dataSource objectForKey:@"sportSteps"];
    for (NSDictionary *dict in tempArray) {
        total += [[dict objectForKey:@"speed"] floatValue] * [[dict objectForKey:@"time"] floatValue] / 60;
    }
    return total;
}


- (BOOL)isSportsCompleted
{
    return continueTime >= totalTime*60 ? YES : NO;
}


#pragma mark - Timer Handler

- (void)prepareHandler:(id)sender
{
    [_countDownImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"num%i.png", prepareCount]]];
    
    prepareCount --;
    
    if (prepareCount < -1) {
        //关闭倒计时计时器：：
        WL_INVALIDATE_TIMER(_prepareTImer);
        _countDownImageView.hidden = YES;
        
        _startTime = localNow();
        [_animationImageView setAnimationImages:_animationImageArray];
        [_animationImageView setAnimationDuration:1.0f];
        [_animationImageView startAnimating];
        
        //开始运动计时器：：
        self.sportRunTimer = [NSTimer scheduledTimerWithTimeInterval:TimerInterval target:self selector:@selector(runTimerHandler:) userInfo:nil repeats:YES];
        [self.sportRunTimer fire];
        
        
    }
}


- (void)runTimerHandler:(id)sender
{
    
    NSArray *stepArray = [_dataSource objectForKey:@"sportSteps"];
    NSDictionary *stepDic = [stepArray objectAtIndex:currentStep];
    
    if (isStart == NO) {
        NSString *TTSString = [NSString stringWithFormat:
                               @"运动已开始，当前为 第%i运动阶段，速度 %@千米每小时，本阶段时间为 %@分钟",
                               currentStep + 1,
                               [stepDic objectForKey:@"speed"],
                               [stepDic objectForKey:@"time"]];
        
        [self IFlySpeakString:TTSString];
        isStart = YES;
    }
    
    continueTime += TimerInterval;
    
    _sportCell.durationTime.text = [self getFormattedContinueTime:continueTime];
    _sportCell.durationDistance.text = [NSString stringWithFormat:@"%.2fkm", [self getDurationDistanceWithTime:continueTime]];
    
    _currentStepLabel.text = [NSString stringWithFormat:@"第%i阶段", currentStep + 1];
    _currentSpeedLabel.text = [NSString stringWithFormat:@"%@km/h", [stepDic objectForKey:@"speed"]];
    _currentStepTimeLabel.text = [NSString stringWithFormat:@"%@min", [stepDic objectForKey:@"time"]];
    
    [_runView movePointerWithTime:continueTime/60];
    
    //20秒钟之前的预报：：
    if ([self getStepRemainSecondsWithContinueTime:continueTime] == 20 ) {
        //语音提示：：
        if (currentStep + 1 == [[_dataSource objectForKey:@"sportSteps"] count]) {
            
            NSString *TTSString = @"本次运动将在20秒后结束";
            [self IFlySpeakString:TTSString];
            
            
        } else {
            NSDictionary *stepInfo = [[_dataSource objectForKey:@"sportSteps"] objectAtIndex:currentStep + 1];
            float nextSpeed = [[stepInfo objectForKey:@"speed"] floatValue];
            
            NSString *TTSString = [NSString stringWithFormat:@"二十秒后速度将被调整为%.1f千米每小时", nextSpeed];
            if ([[_dataSource objectForKey:@"generation"] floatValue] <= 2.5) {
                TTSString = [NSString stringWithFormat:@"二十秒后请您将速度调节为%.1f千米每小时", nextSpeed];
            }
            [self IFlySpeakString:TTSString];
        }
    }
    
    int step = [self getCurrentStepWithTime:continueTime];
    if (currentStep != step) {
        //说明运动阶段变化了：：
        currentStep = step;
        
        [self commitSport];
        [self getConnectStatus];
        [self sendControlCommand:@"PBJ_MODIFY_SPEED_SLOPE"];        //发送修改速度、坡度的请求
    }
    
    if ([self isSportsCompleted]) {
        //运动结束了：：
        [self sportOver];
    }
    
}

#pragma mark - IFlySpeak

- (void)IFlySpeakTrainMessage:(NSString *)TTSString
{
    if (!shouldPlayTrainSound) {
        return;
    }
    if (isIFlySpeechPlaying == NO) {
        [_iFlySpeechSynthesizer startSpeaking:TTSString];
    } else {
        return;
    }
}

- (void)IFlySpeakString:(NSString *)TTSString
{
    if (!shouldPlaySystemSound) {
        return;
    }
    if (isIFlySpeechPlaying == NO) {
        [_iFlySpeechSynthesizer startSpeaking:TTSString];
    } else {
        return;
    }
}

- (void)getConnectStatus
{
    //发送连接状态请求：：
    [self sendRequest:
     
     @{
     @"barcodeid": _barDecode,
     @"pwd": [DBM dbm].currentUsers.pwd
     }
               action:Equip_Connect_Request
        baseUrlString:_bdrConnPath];
}

- (void)commitSport
{
    if (!_startTime) {
        _startTime = localNow();
    }
    if (!_endTime) {
        _endTime = localNow();
    }
    
    
    
    [self sendRequest:
     
     @{@"prescriptionId": [_dataSource objectForKey:@"prescriptionId"],
     @"barcodeId": _barDecode,
     @"memberId": [DBM dbm].currentUsers.memberId,
     @"pwd": [DBM dbm].currentUsers.pwd,
     @"startTime": getDateStringWithNSDateAndDateFormat(_startTime, nil),
     @"endTime": getDateStringWithNSDateAndDateFormat(_endTime, nil),
     @"totalTime": [NSNumber numberWithFloat:continueTime/60],
     @"result": [NSNumber numberWithBool:[self isSportsCompleted]]
     }
     
               action:wlInsertPrescriptionResult
        baseUrlString:wlServer];
}

- (void)sportPauseSpeak
{
    NSString *TTSString = [NSString stringWithFormat:
                           @"运动已暂停，已运动%.2f公里，时长%.1f分钟",
                           [self getDurationDistanceWithTime:continueTime],
                           continueTime/60];
    [self IFlySpeakString:TTSString];
}

#pragma mark - Control Button

- (IBAction)controllButtonHandler:(id)sender
{
    if(self.dataSource.count ==0){
        return;
    }
    
    switch (self.sportCell.sportButtonState) {
            
        case SportButtonStatePause:
            //如果点击之前的状态为：：暂停
            
            //------------想要中途暂停-----------
            [_wlhyXmpp sendMessage:@"我暂停了本次运动"];
            [self sportPauseSpeak];
            self.sportCell.sportButtonState=SportButtonStateStart;
            [_animationImageView stopAnimating];
            [_animationImageView setImage:[UIImage imageNamed:@"stand.png"]];
            isIFlySpeechPlaying = NO;
            [_iFlySpeechSynthesizer startSpeaking:@"运动已暂停"];
            WL_INVALIDATE_TIMER(self.sportRunTimer);
            [self commitSport];
            [self sendControlCommand:@"PBJ_PAUSE"];
            
            break;
            
        case SportButtonStateStart:
            //如果点击之前的状态为：：正在进行
            
            if(!isStart){
                //-----------刚开始-----------
                [self sportStart];
                
            } else {
                //-----------想在暂停后之后继续-------
                [self sportStart];
            }
            
            break;
            
        case SportButtonStateStop:
            //点击之前的状态为：：已经结束
            [self showText:@"运动已结束"];
            break;
            
        default:
            break;
    }
}

#pragma mark - Send Equip Control Command

- (void)sendControlCommand:(NSString *)command
{
    
    if (!isServerConnected) {
        return;
    }
    
    NSString *actionString = Equip_Command_Request;
    
    NSArray *stepsArray = [_dataSource objectForKey:@"sportSteps"];
    NSDictionary *stepInfo = [stepsArray objectAtIndex:currentStep];
    
    NSArray *paramsArray = [NSArray arrayWithObjects:
                            [stepInfo objectForKey:@"speed"],
                            [stepInfo objectForKey:@"slope"], nil];
    
    //    _bdrConnPath = @"http://218.245.5.74:8888";
    
    
    //0001000000260001
    //0001000000360000
    
    [self sendRequest:
     
     @{@"barcodeid": _barDecode,
     @"memberid": [DBM dbm].currentUsers.memberId,
     @"cmd": command,
     @"params": paramsArray}
     
               action:actionString
        baseUrlString:_bdrConnPath];
    
}

#pragma mark - commit and sport end

- (void)sportStart
{
    self.sportCell.sportButtonState = SportButtonStatePause;
    
    WL_INVALIDATE_TIMER(self.sportRunTimer);
    [self sendControlCommand:@"PBJ_START"];
    
    prepareCount = 3;
    _countDownImageView.hidden = NO;
    _prepareTImer = [NSTimer scheduledTimerWithTimeInterval:0.73 target:self selector:@selector(prepareHandler:) userInfo:nil repeats:YES];
    
    if (shouldPlaySystemSound) {
        //播放倒计时提示音：：
        NSString *musicFilePath = [[NSBundle mainBundle] pathForResource:@"mpnewbeep" ofType:@"mp3"];       //创建音乐文件路径
        NSURL *musicURL = [[NSURL alloc] initFileURLWithPath:musicFilePath];
        if (!_audioPlayer) {
            _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
        }
        
        [_audioPlayer stop];
        [_audioPlayer prepareToPlay];
        [_audioPlayer setVolume:0.2f];   //设置音量大小
        _audioPlayer.numberOfLoops = 0;//设置音乐播放次数  -1为一直循环
        [_audioPlayer play];   //播放
    }
    
    
    NSString *messageString = [NSString stringWithFormat:@"我在椭圆机上开始了运动，当前为第%i阶段", currentStep+1];
    [_wlhyXmpp sendMessage:messageString];
    
}

- (void)sportOver
{
    WL_INVALIDATE_TIMER(self.sportRunTimer);
    _endTime = localNow();
    
    NSString *TTSString = [NSString stringWithFormat:
                           @"运动已结束，本次运动总长度为%.2f千米，总耗时%.1f分钟，总能耗%@千卡",
                           totalDistance,
                           continueTime/60,
                           [_dataSource objectForKey:@"goalEnergyConsumption"]];
    [self IFlySpeakString:TTSString];
    
    //修改本地数据：：
    UsersExt *usersExt = [DBM dbm].usersExt;
    usersExt.totalTime = [NSString stringWithFormat:@"%.2f", [usersExt.totalTime floatValue] + continueTime/60];
    usersExt.totalEnergy = [NSString stringWithFormat:@"%.2f", [usersExt.totalEnergy floatValue] + [[_dataSource objectForKey:@"goalEnergyConsumption"] floatValue]];
    
    [self commitSport];
    [self showText:@"运动已结束"];
    
    self.sportCell.sportButtonState = SportButtonStateStop;
    [_animationImageView stopAnimating];
    
    [self showActionSheet];
}



#pragma mark - UI Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%i", buttonIndex);
    
    if (buttonIndex <= 3) {
        [self sendRequest:
         
         @{@"memberid": [DBM dbm].currentUsers.memberId,
         @"pwd": [DBM dbm].currentUsers.pwd,
         @"prescriptionid": _prescriptionId,
         @"result": [NSNumber numberWithInt:buttonIndex]}
         
                   action:wlUpdateExerciseFeelings
            baseUrlString:wlServer];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //用户确实要离开：：
        [self storeSportsData];
        
        UIViewController *destVC = [self.navigationController.viewControllers objectAtIndex:2];
        if ([destVC respondsToSelector:@selector(setIsBackFromTrainSelection:)]) {
            [destVC setValue:@NO forKey:@"isBackFromTrainSelection"];
        }
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2]animated:YES];
    }
}


//=======================================================================

#pragma mark - processRequest

-(void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"back action :: %@", action);
    NSLog(@"info :: %@ , error :: %@", info, error);
    
    if ([action isEqualToString:wlInsertPrescriptionResult]) {
        //--------------提交运动成功---------------
        if (info) {
            if([[info objectForKey:@"errorCode"] intValue] == 0) {
                [self showText:[info objectForKey:@"errorDesc"]];
            } else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
        } else {
            [self showText:@"连接服务器失败！"];
        }
        
    } else if ([action isEqualToString:wlUpdateExerciseFeelings]) {
        if (info) {
            if([[info objectForKey:@"errorCode"] intValue] == 0) {
                [self showText:@"您已完成本次计划，增加一个能量积分"];
            } else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
        } else {
            [self showText:@"连接服务器失败！"];
        }
        
    } else if ([action isEqualToString:Equip_Connect_Request]) {
        //--------------【连接状态】请求得到回复------------
        if (info) {
            if([[info objectForKey:@"errorcode"] intValue] == 1) {
                _equipConnectionStateLabel.text = @"正常";
                _serverConnectionStateLabel.text = @"正常";
                isServerConnected = YES;
            } else {
                _equipConnectionStateLabel.text = @"未连接";
                _equipConnectionStateLabel.textColor = [UIColor colorWithRed:0.7 green:0.4 blue:0.4 alpha:1.0];
                _serverConnectionStateLabel.text = @"正常";
            }
            
        } else {
            _equipConnectionStateLabel.text = @"未连接";
            _serverConnectionStateLabel.text = @"未连接";
            _equipConnectionStateLabel.textColor = [UIColor colorWithRed:0.7 green:0.4 blue:0.4 alpha:1.0];
            _serverConnectionStateLabel.textColor = [UIColor colorWithRed:0.7 green:0.4 blue:0.4 alpha:1.0];
        }
    } else if ([action isEqualToString:wlGetCertainTrainInfoRequest]) {
        //获取指导私教信息回复：：
        if (info) {
            if([[info objectForKey:@"errorCode"] intValue] == 0) {
                [self showText:@"私教在线，可进行实时健身指导"];
                _wlhyXmpp = [WlhyXMPP WlhyXMPP];
                [_wlhyXmpp connect];
                [_wlhyXmpp setDelegate:self];
                [_wlhyXmpp setMate:[info objectForKey:@"account"] serverName:[DBM dbm].currentUsers.imServerName];
            } else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
        } else {
            [self showText:@"连接服务器失败！"];
        }
        
    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"totalShowCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if(indexPath.section == 0){
        WlhySportTotalCell *sportCell = (WlhySportTotalCell*)cell;
        _sportCell=sportCell;
        
        _sportCell.totalTime.text= [NSString stringWithFormat:@"%.1f",totalTime];
        _sportCell.totalKal.text=[NSString stringWithFormat: @"%@",WlhyString([_dataSource objectForKey:@"goalEnergyConsumption"])];
        _sportCell.totalDistance.text=[NSString stringWithFormat:@"%.2f",totalDistance];
        if ([self isSportsCompleted]) {
            _sportCell.sportButtonState = SportButtonStateStop;
        }
        
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"运动统计";
}


//=======================================================================

#pragma mark - IFlySpeechSynthesizerDelegate

- (void) onSpeakBegin
{
    isIFlySpeechPlaying = YES;
    return;
}

- (void) onBufferProgress:(int) progress message:(NSString *)msg
{
    NSLog(@"bufferProgress:%d,message:%@",progress,msg);
}

- (void) onSpeakProgress:(int) progress
{
    NSLog(@"play progress:%d", progress);
}

- (void) onSpeakPaused
{
    return;
}

- (void) onSpeakResumed
{
    return;
}

- (void) onCompleted:(IFlySpeechError *) error
{
    NSLog(@"error :: %@", error);
    isIFlySpeechPlaying = NO;
    return;
}

- (void) onSpeakCancel
{
    return;
}


@end
