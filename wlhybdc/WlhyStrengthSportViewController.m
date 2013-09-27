//
//  WlhyStrengthSportViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-2.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyStrengthSportViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"

#import "FileManage.h"
#import "WlhyXMPP.h"
#import "SportGuideMessageView.h"
#import "DropButtonView.h"

#define Equip_Command_Request @"/BdrServer/CmdSendApi"
#define Equip_Connect_Request @"/BdrServer/ConnectStateApi"

static CGFloat TimerInterval = 0.5f;

typedef enum {
    SportButtonStateStart,
    SportButtonStatePause,
    SportButtonStateStop
}SportButtonState;

@interface WlhyStrengthSportCell : UITableViewCell


@property(nonatomic,assign) SportButtonState sportButtonState;

@property (strong, nonatomic) IBOutlet UILabel *currentStep;
@property (strong, nonatomic) IBOutlet UILabel *remainTime;
@property (strong, nonatomic) IBOutlet UIButton *sportStartButton;


@end


@implementation WlhyStrengthSportCell

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

-(void)setSportButtonState:(SportButtonState)sportButtonState
{
    _sportButtonState=sportButtonState;
    
    switch (sportButtonState) {
        case SportButtonStatePause:
            
            [self.sportStartButton setImage:[UIImage imageNamed:@"sport_b0"] forState:UIControlStateNormal];
            [self.sportStartButton setImage:[UIImage imageNamed:@"sport_b1"] forState:UIControlStateHighlighted];
            
            break;
        case SportButtonStateStop:
            
            [self.sportStartButton setImage:[UIImage imageNamed:@"sport_c0"] forState:UIControlStateNormal];
            [self.sportStartButton setImage:[UIImage imageNamed:@"sport_c1"] forState:UIControlStateHighlighted];
            
            break;
            
        case SportButtonStateStart:
        default:
            [self.sportStartButton setImage:[UIImage imageNamed:@"sport_a0"] forState:UIControlStateNormal];
            [self.sportStartButton setImage:[UIImage imageNamed:@"sport_a1"] forState:UIControlStateHighlighted];
            break;
            
    }
}


@end


//====================================================================================
//====================================================================================


@interface WlhyStrengthSportViewController () <IFlySpeechSynthesizerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate, UIAlertViewDelegate, UIActionSheetDelegate, WlhyXMPPDelegate, DropButtonViewDelegate>
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

@property(strong, nonatomic) IBOutlet UILabel *serverConnectionStateLabel;
@property(strong, nonatomic) IBOutlet UILabel *equipConnectionStateLabel;

@property(strong, nonatomic) IBOutlet UIImageView *animationImageView;
@property(strong, nonatomic) IBOutlet UIImageView *countDownImageView;


@property(strong, nonatomic) IFlySpeechSynthesizer *iFlySpeechSynthesizer;
@property(nonatomic, strong) WlhyStrengthSportCell *strengthSportCell;
@property(strong, nonatomic) AVAudioPlayer *audioPlayer;


@property(nonatomic,strong) NSString *bdrConnPath;

@property(nonatomic,strong) NSTimer *prepareTImer;
@property(nonatomic,strong) NSTimer *sportRunTimer;
@property(nonatomic,strong) NSDate * startTime;
@property(nonatomic,strong) NSDate * endTime;
@property(nonatomic,strong) NSDate * storeTime;
@property(nonatomic, strong) NSMutableArray *animationImageArray;

@property(strong, nonatomic) DropButtonView *dropButtonView;

@property(strong, nonatomic) WlhyXMPP *wlhyXmpp;
@property(strong, nonatomic) SportGuideMessageView *sportGuideMessageView;


- (IBAction)controllButtonHandler:(id)sender;


@end



@implementation WlhyStrengthSportViewController


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
    
    //页面出现的时候，根据私教id去请求私教详细信息：：
    if ([_trainID intValue] > 0) {
        [self sendRequest:
         
         @{@"memberId":[DBM dbm].currentUsers.memberId,
         @"pwd":[DBM dbm].currentUsers.pwd,
         @"servicePersonId": _trainID}
         
                   action:wlGetCertainTrainInfoRequest
            baseUrlString:wlServer];
    }
    
    [self getSportsData];
    NSLog(@"%@", _dataSource);
    
    [self getConnectStatus];
    
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
    
    self.iFlySpeechSynthesizer = nil;
    self.audioPlayer = nil;
    
    self.prepareTImer = nil;
    self.sportRunTimer = nil;
    self.startTime = nil;
    self.endTime = nil;
    self.storeTime = nil;
    self.animationImageArray = nil;
    
    
    self.serverConnectionStateLabel = nil;
    self.equipConnectionStateLabel = nil;
    self.dropButtonView = nil;
    self.bdrConnPath = nil;

    
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

- (void)rightItemTouched:(id)sender
{
    
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
            [self showText:@"您今天已经完成了该处方"];
        }
    }
    
    totalTime = [self getTotalTime];
    
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

- (NSString *)getFormattedContinueTime:(float)time
{
    //传入的time参数的单位是：秒
    int minute = time / 60;
    int second = time - minute * 60;
    NSString *formattedTime = [NSString stringWithFormat:@"%i:%i", minute, second];
    return formattedTime;
}

//time :: 已经过去的持续时间，单位：秒
- (int)getRemainSportSecondsWithContinueTime:(float)time
{
    NSArray *stepArray = [_dataSource objectForKey:@"sportSteps"];
    float stepEndTime = 0.0;
    
    NSDictionary *stepInfo;
    for (int i = 0; i < currentStep; i++) {
        stepInfo = [stepArray objectAtIndex:i];
        stepEndTime += [[stepInfo objectForKey:@"resttime"] floatValue] + [[stepInfo objectForKey:@"time"] floatValue]*60;
    }
    stepInfo = [stepArray objectAtIndex:currentStep];
    stepEndTime += [[stepInfo objectForKey:@"time"] floatValue]*60;
    
    int remainSeconds = stepEndTime - time;
    NSLog(@"RemainSportSeconds == %i", remainSeconds);
    return remainSeconds;
}

- (int)getRemainRestSecondsWithContinueTime:(float)time
{
    NSArray *stepArray = [_dataSource objectForKey:@"sportSteps"];
    float stepEndTime = 0.0;
    
    for (int i = 0; i <= currentStep; i++) {
        NSDictionary *stepInfo = [stepArray objectAtIndex:i];
        stepEndTime += [[stepInfo objectForKey:@"resttime"] floatValue] + [[stepInfo objectForKey:@"time"] floatValue]*60;
    }
    
    int remainSeconds = stepEndTime - time;
    NSLog(@"RemainRestSeconds == %i", remainSeconds);
    return remainSeconds;
}

- (int)getCurrentStepWithTime:(float)time
{
    int step = 0;
    float timeSum = 0.0;
    
    NSArray *stepArray = [_dataSource objectForKey:@"sportSteps"];
    for (int i = 0; i < stepArray.count; i++) {
        NSDictionary *stepInfo = [stepArray objectAtIndex:i];
        timeSum += [[stepInfo objectForKey:@"resttime"] floatValue] + [[stepInfo objectForKey:@"time"] floatValue]*60;
        if (time <= timeSum) {
            step = i;
            break;
        }
    }
    return step;
}

- (CGFloat)getTotalTime
{
    /*
     {
     bigStep = "";
     contents = "";
     frequency = 20;
     resttime = 30;
     slope = "";
     smallStep = "";
     speed = "";
     step = 3;
     strength = 3;
     time = "0.5";
     title = "\U7b2c\U4e09\U7ec4";
     }
     */
    
    CGFloat  total = 0.0f;
    NSArray *tempArray = [_dataSource objectForKey:@"sportSteps"];
    for (NSDictionary *dict in tempArray) {
        total += [[dict objectForKey:@"resttime"] floatValue] + [[dict objectForKey:@"time"] floatValue]*60;
    }
    return total;//单位：秒
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
    
    /*
     {
     bigStep = "";
     contents = "";
     frequency = 20;
     resttime = 30;
     slope = "";
     smallStep = "";
     speed = "";
     step = 1;
     strength = 1;
     time = "0.5";
     title = "\U7b2c\U4e00\U7ec4";
     }
    */
    if (isStart == NO) {
        NSDictionary *stepDic = [stepArray objectAtIndex:currentStep];
        NSString *TTSString = [NSString stringWithFormat:
                               @"开始第%i组，时间 %@分钟，运动%@次，强度为%@，休息 %@秒",
                               currentStep + 1,
                               [stepDic objectForKey:@"time"],
                               [stepDic objectForKey:@"frequency"],
                               [stepDic objectForKey:@"strength"],
                               [stepDic objectForKey:@"resttime"]];
        [self IFlySpeakString:TTSString];
        isStart = YES;
    }
    
    continueTime += TimerInterval;
    
    if ([_strengthSportCell.currentStep.text isEqualToString:@"间歇休息"]) {
        //休息倒计时中：：
        int remainRestTime = [self getRemainRestSecondsWithContinueTime:continueTime];
        _strengthSportCell.remainTime.text = [NSString stringWithFormat:@"%i S", remainRestTime];
    } else {
        //运动倒计时：：
        int remainSportTime = [self getRemainSportSecondsWithContinueTime:continueTime];
        _strengthSportCell.currentStep.text = [NSString stringWithFormat:@"第%i组", currentStep + 1];
        _strengthSportCell.remainTime.text = [NSString stringWithFormat:@"%i S", remainSportTime];
        
        if (remainSportTime == 0 ) {
            //语音提示：：
            if (currentStep + 1 < [[_dataSource objectForKey:@"sportSteps"] count]) {
                
                NSDictionary *stepInfo = [[_dataSource objectForKey:@"sportSteps"] objectAtIndex:currentStep + 1];
                NSString *TTSString = [NSString stringWithFormat:@"第%i组完成，请休息%@秒，强度调整为%@",
                                       currentStep + 1,
                                       [stepInfo objectForKey:@"resttime"],
                                       [stepInfo objectForKey:@"strength"]];
                [self IFlySpeakString:TTSString];
                _strengthSportCell.currentStep.text = @"间歇休息";
                
            }
        }
    }
    
    int step = [self getCurrentStepWithTime:continueTime];
    NSLog(@"step == %i", step);
    if (currentStep != step) {
        //说明运动阶段变化了：：
        currentStep = step;
        
        if (currentStep < stepArray.count - 1) {
            NSDictionary *stepInfo = [stepArray objectAtIndex:currentStep];
            NSString *TTSString = [NSString stringWithFormat:
                                   @"开始第%i组，时间 %@分钟，运动%@次，强度为%@，休息 %@秒",
                                   currentStep + 1,
                                   [stepInfo objectForKey:@"time"],
                                   [stepInfo objectForKey:@"frequency"],
                                   [stepInfo objectForKey:@"strength"],
                                   [stepInfo objectForKey:@"resttime"]];
            [self IFlySpeakString:TTSString];
            [self getConnectStatus];
        } else {
            //运动全部结束：：
            [self sportOver];
        }
        
        [self commitSport];
        [self.tableView reloadData];
    }
    
}

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


#pragma mark - Control Button

- (IBAction)controllButtonHandler:(id)sender
{
    if(self.dataSource.count ==0){
        return;
    }

    switch (_strengthSportCell.sportButtonState) {
            
        case SportButtonStatePause:
            //如果点击之前的状态为：：暂停
            
            //------------想要中途暂停-----------
            [_wlhyXmpp sendMessage:@"我暂停了本次运动"];
            [self sportPause];
            break;
            
        case SportButtonStateStart:
            [self sportStart];
            break;
            
        case SportButtonStateStop:
            //点击之前的状态为：：已经结束
            [self showText:@"运动已结束"];
            break;
            
        default:
            break;
    }
}


#pragma mark - commit and sport end

- (void)sportPause
{
    _strengthSportCell.sportButtonState = SportButtonStateStart;
    [_animationImageView stopAnimating];
    isIFlySpeechPlaying = NO;
    
    NSString *TTSString = [NSString stringWithFormat:
                           @"运动暂停，已运动%.0f秒",
                           continueTime];
    [self IFlySpeakString:TTSString];
    
    WL_INVALIDATE_TIMER(self.sportRunTimer);
    [self commitSport];

}

- (void)sportStart
{
    _strengthSportCell.sportButtonState = SportButtonStatePause;
    
    WL_INVALIDATE_TIMER(self.sportRunTimer);
    
    prepareCount = 3;
    _countDownImageView.hidden = NO;
    _prepareTImer = [NSTimer scheduledTimerWithTimeInterval:0.73 target:self selector:@selector(prepareHandler:) userInfo:nil repeats:YES];
    
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
    
    _strengthSportCell.sportButtonState = SportButtonStatePause;
    
    NSString *messageString = [NSString stringWithFormat:@"我在力量训练器上开始了运动，当前为第%i阶段", currentStep+1];
    [_wlhyXmpp sendMessage:messageString];
    
}

- (void)sportOver
{
    WL_INVALIDATE_TIMER(self.sportRunTimer);
    _endTime = localNow();
    
    NSString *TTSString = [NSString stringWithFormat:@"运动已结束，共运动%.1f分钟", totalTime/60];
    [self IFlySpeakString:TTSString];
    
    [self showText:@"运动已结束"];
    
    _strengthSportCell.sportButtonState = SportButtonStateStop;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        
        case 1:
            return [[_dataSource objectForKey:@"sportSteps"] count];
            break;
            
        default:
            break;
    }
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NULL;
            break;
        
        case 1:
            return @"运动步骤";
            break;
            
        default:
            break;
    }
    return NULL;
}

/*
 {
 bdrConnPath = "http://218.245.5.74:8888";
 companyid = 001004003;
 equipType = 1003;
 errorCode = 0;
 errorDesc = "\U83b7\U5f97\U5904\U65b9\U6210\U529f";
 exeResult = "";
 exerciseGoals = "\U63d0\U9ad8\U5fc3\U80ba\U529f\U80fd";
 generation = 3;
 gifPath = "http://www.holddo.com/bdcServer/img/equip/001004003_LL130905001_1378349349265.png";
 goalEnergyConsumption = 601;
 name = "\U529b\U91cf\U8bad\U7ec3\U5668";
 note = "\U8010\U529b\U8bad\U7ec3\U8981\U91cf\U529b\U800c\U884c\Uff0c\U6ce8\U610f\U6b21\U6570\U8981\U5408\U7406\Uff0c\U6839\U636e\U81ea\U5df1\U80fd\U627f\U62c5\U7684\U6700\U5927\U91cd\U91cf\U768440~60%\U8fdb\U884c\U8c03\U6574\Uff0c\U6bcf\U7ec4\U65f6\U95f4\U95f4\U9694\U572830\U79d2\U5de6\U53f3.";
 prescriptionId = "1d2a9fda-7bc4-44bf-80c2-b6d0e79b9f6f";
 prescriptionValue = "\U901a\U8fc7\U529b\U91cf\U8010\U529b\U7684\U8bad\U7ec3\Uff0c\U80fd\U589e\U957f\U8010\U529b\Uff0c\U63d0\U9ad8\U808c\U8089\U6027\U80fd\Uff0c\U589e\U5f3a\U4f53\U8d28\U6c34\U5e73\U3002";
 sfxx = 1;
 slopeUnits = "";
 sportPattern = "\U6301\U7eed\U8fd0\U52a8";
 sportShowType = 1;
 sportSteps =     (
 {
 bigStep = "";
 contents = "";
 frequency = 20;
 resttime = 30;
 slope = "";
 smallStep = "";
 speed = "";
 step = 1;
 strength = 1;
 time = "0.5";
 title = "\U7b2c\U4e00\U7ec4";
 },
 {
 bigStep = "";
 contents = "";
 frequency = 30;
 resttime = 30;
 slope = "";
 smallStep = "";
 speed = "";
 step = 2;
 strength = 2;
 time = "0.5";
 title = "\U7b2c\U4e8c\U7ec4";
 },
 {
 bigStep = "";
 contents = "";
 frequency = 20;
 resttime = 30;
 slope = "";
 smallStep = "";
 speed = "";
 step = 3;
 strength = 3;
 time = "0.5";
 title = "\U7b2c\U4e09\U7ec4";
 },
 {
 bigStep = "";
 contents = "";
 frequency = 30;
 resttime = 30;
 slope = "";
 smallStep = "";
 speed = "";
 step = 4;
 strength = 4;
 time = "0.5";
 title = "\U7b2c\U56db\U7ec4";
 }
 );
 },-----,(null)
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 0){
        
        _strengthSportCell = [tableView dequeueReusableCellWithIdentifier:@"StrengthSportCell"];
        if (!_strengthSportCell) {
            _strengthSportCell = [[WlhyStrengthSportCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StrengthSportCell"];
        }
        
        if (!isStart) {
            _strengthSportCell.currentStep.text = @"未开始";
        } else {
            _strengthSportCell.currentStep.text = [NSString stringWithFormat:@"第%i组", currentStep + 1];
        }
        _strengthSportCell.remainTime.text = [NSString stringWithFormat:@"%i S",
                                              [self getRemainSportSecondsWithContinueTime:continueTime]];
        if ([self isSportsCompleted]) {
            _strengthSportCell.sportButtonState = SportButtonStateStop;
        }
        return _strengthSportCell;
        
    } else if (indexPath.section == 1) {
        
        NSDictionary *prescStepItemInfo = [[_dataSource objectForKey:@"sportSteps"] objectAtIndex:indexPath.row];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StrengthStepCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StrengthStepCell"];
        }
        
        cell.textLabel.textColor = (currentStep == indexPath.row) ? [UIColor colorWithRed:0.5 green:0.9 blue:0.5 alpha:1.0] : [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        cell.textLabel.text = [NSString stringWithFormat:@"第%@组：运动%@次，%@分钟，休息%@秒，强度%@",
                               [prescStepItemInfo objectForKey:@"step"],
                               [prescStepItemInfo objectForKey:@"frequency"],
                               [prescStepItemInfo objectForKey:@"time"],
                               [prescStepItemInfo objectForKey:@"resttime"],
                               [prescStepItemInfo objectForKey:@"strength"]];
        return cell;
    }
    
    return NULL;
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
