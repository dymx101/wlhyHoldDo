//
//  WlhyHomeViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-11.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyHomeViewController.h"

#import <AudioToolbox/AudioToolbox.h>

#import "WlhyHomeTitleViewController.h"
#import "WlhyLauncherViewController.h"
#import "JHTickerView.h"
#import "CMPopTipView.h"
#import "WlhyXMPP.h"
#import "FileManage.h"
#import "HomeTitleView.h"



//============================================================================================================
//============================================================================================================


@interface WlhyHomeViewController () 

@property (strong, nonatomic) IBOutlet UIView *launcherView;

@property(nonatomic,readonly,strong) WlhyHomeTitleViewController *homeTitleViewController;
@property(strong, nonatomic) WlhyLauncherViewController *launcherViewController;

@property(strong, nonatomic) WlhyXMPP *wlhyXmpp;

@property(strong, nonatomic) IBOutlet UILabel *goalLabel;
@property(strong, nonatomic) IBOutlet UILabel *paramLabel;
@property(strong, nonatomic) IBOutlet JHTickerView *tickerView;

@property(strong, nonatomic) HomeTitleView *titleView;

@property(strong, nonatomic) UIImageView *backgroundImageView;  //不删

- (IBAction)weatherButtonTouched:(id)sender;
- (IBAction)startNewSport:(id)sender;

@end

@implementation WlhyHomeViewController

@synthesize homeTitleViewController=_homeTitleViewController;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showViewControllerByIdentifier:) name:wlhyShowViewControllerNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeNumber:) name:wlhyUpdateBadgeNumberNotification object:nil];
    }
    return self;
}

#pragma mark - VC life

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=NO;
    self.title = @"欢迎会员";
    
    if (![DBM dbm].isLogined) {
        [self handlerAutoLogin];
    }
    
    [self setUI];
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i< 10; i++) {
        NSString *str = [NSString stringWithFormat:@"object : %i", i];
        [arr addObject:str];
    }
    
    [_tickerView setDirection:JHTickerDirectionLTR];
    [_tickerView setLoops:YES];
    [_tickerView setTickerSpeed:35.0f];
    [_tickerView start];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    }
    
    if ([deviceType() isEqualToString:@"OldScreen"]) {
        [_backgroundImageView setImage:[UIImage imageNamed:@"index.jpg"]];
    } else {
        [_backgroundImageView setImage:[UIImage imageNamed:@"index1040.jpg"]];
    }
    [self.tableView setBackgroundView:_backgroundImageView];
    
    [self updateBadgeNumber:nil];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_launcherView setFrame:CGRectMake(5, self.view.frame.size.height - 205,
                                       self.view.frame.size.width - 10, 200)];
    [self updateOverView];
    [self updateDisplay];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.launcherView = nil;
        self.launcherViewController = nil;
        self.goalLabel = nil;
        self.paramLabel = nil;
        self.tickerView = nil;
        self.titleView = nil;
        self.backgroundImageView = nil;
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:wlhyShowViewControllerNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:wlhyUpdateBadgeNumberNotification object:nil];
}

- (IBAction)weatherButtonTouched:(id)sender
{
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyWeatherViewController"];
    if (destVC) {
        [self.navigationController pushViewController:destVC animated:YES];
    }
}

#pragma mark - UI

- (void)setUI
{
    if (!_launcherView) {
        _launcherView = [[UIView alloc] initWithFrame:CGRectMake(5, self.view.frame.size.height - 205,
                                                                self.view.frame.size.width - 10, 200)];
    }
    self.launcherView.layer.cornerRadius = 8;
    self.launcherView.layer.borderWidth = 1;
    self.launcherView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;
    self.launcherView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.75];
    [self.view addSubview:_launcherView];
    
    if (!_launcherViewController) {
        _launcherViewController = [[WlhyLauncherViewController alloc] init];
    }
    
    [self addSubViewController:_launcherViewController toView:self.launcherView];
    
    WlhyHomeTitleViewController *homeTitleViewController = self.homeTitleViewController;
    [self.view addSubview: homeTitleViewController.view];
    
}

#pragma mark - XMPP SET

- (void)setXmppStream
{
    
    if (!_wlhyXmpp) {
        _wlhyXmpp = [WlhyXMPP WlhyXMPP];
    }
    [_wlhyXmpp connect];
    
}

- (void)updateOverView
{
    
    /*
     {
     errorCode = 0;
     errorDesc = "\U67e5\U8be2\U5904\U65b9\U6982\U51b5\U6210\U529f";
     exerciseGoals = "\U63d0\U9ad8\U5fc3\U80ba\U529f\U80fd";
     exerciseProgram = "1\U3001\U8dd1\U6b65\U673a";
     friendTips = "\U6309\U7167\U5904\U65b9\U63a8\U8350\U7684\U6b21\U5e8f\U8fdb\U884c\U5065\U8eab\U80fd\U5927\U5e45\U5ea6\U63d0\U9ad8\U5065\U8eab\U7684\U6548\U679c\Uff0c\U907f\U514d\U8fd0\U52a8\U4f24\U5bb3\U3002";
     plannedGoal = 5;
     prescriptionId = "1d2a9fda-7bc4-44bf-80c2-b6d0e79b9f6f";
     restflag = 1;
     tips = "\U8981\U575a\U6301\U79d1\U5b66\U6709\U89c4\U5f8b\U7684\U8fd0\U52a8\Uff0c\U5426\U5219\U52a8\U4e0d\U5982\U4e0d\U52a8\U3002";
     }
     */
    
    
    
    _goalLabel.text = [DBM dbm].prescription.exerciseGoals;
    if ([[DBM dbm].prescription.exerciseGoals isEqualToString:@""] || [DBM dbm].prescription.exerciseGoals == nil) {
        _goalLabel.text = @"暂无数据";
    }
    _paramLabel.text = [DBM dbm].prescription.exerciseProgram;
    if ([[DBM dbm].prescription.exerciseProgram isEqualToString:@""] || [DBM dbm].prescription.exerciseProgram == nil) {
        _paramLabel.text = @"暂无数据";
    }
    
    NSString *tipsString = @"";
    NSString *memberStatus = [[DBM dbm] usersExt].memberStatus;
    NSNumber *memberID = [[DBM dbm] currentUsers].memberId;
    NSLog(@"%@ , %i", memberStatus, [memberID intValue]);
    
    if ([memberID intValue] == 0 && [memberStatus isEqualToString:@""]) {
        tipsString = @"慧动健身友情提示：注册会员后可享受更多服务。";
    }
    if ([memberID intValue] != 0 && [memberStatus isEqualToString:@""]) {
        tipsString = [NSString stringWithFormat:@"您的账户状态为：%@，激活后可享受更多服务。", getMemberStatus()];
    }
    if ([memberStatus intValue] == 2) {
        //已过期：：
        tipsString = [NSString stringWithFormat:@"您的账户状态为：%@，激活后可享受更多服务。", getMemberStatus()];
    }
    if ([memberStatus intValue] == 1) {
        //账户正常：：
        
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *flagDic = [userDefaults dictionaryForKey:@"TodaySportStatus"];
        
        
        if (flagDic) {
            NSString *storeTime = getDateStringWithNSDateAndDateFormat([flagDic objectForKey:@"storeTime"], @"yyyy-MM-dd");
            if (storeTime != nil &&
                ![storeTime isEqualToString: getDateStringWithNSDateAndDateFormat([NSDate date], @"yyyy-MM-dd")]) {
                [userDefaults removeObjectForKey:@"TodaySportStatus"];
            } else {
                int isOver = [[flagDic objectForKey:@"isOver"] intValue];
                
                if (isOver == 0) {
                    //未开始：：
                    tipsString = [NSString stringWithFormat:@"您的账户状态为：%@，扫描器械后可执行处方！", getMemberStatus()];
                } else if (isOver == 1) {
                    //未完成：：
                    tipsString = [NSString stringWithFormat:@"您的账户状态为：%@，您的今日处方未完成，请继续执行！", getMemberStatus()];
                } else if (isOver == 2) {
                    //已完成：：
                    tipsString = [NSString stringWithFormat:@"您的账户状态为：%@，您的今日处方已经执行完毕，请坚持！", getMemberStatus()];
                }
            }
            
        } else {
            tipsString = [NSString stringWithFormat:@"您的账户状态为：%@，请尽快扫描器械，以获取您的运动计划！", getMemberStatus()];
        }
    }
    
    [self.tableView reloadData];
    [_tickerView setTickerStrings:[NSArray arrayWithObject:tipsString]];
    
    

}

- (void)getPrescriptionOverviewAction
{
    
    if(![DBM dbm].isLogined) {
        return;
    }
 
    DBM *dbm = [DBM dbm];
    
    [self sendRequest:
     
     @{@"memberId":dbm.currentUsers.memberId,
     @"pwd":dbm.currentUsers.pwd}
     
               action:wlGetPrescriptionOverviewRequest
     baseUrlString:wlServer];
}

- (void)updateDisplay
{
    if (!_titleView) {
        _titleView = [[HomeTitleView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    }
    [_titleView updateDisplay];
    
    self.navigationItem.titleView = _titleView;
    
    [_homeTitleViewController updateDisplay];
}


- (WlhyHomeTitleViewController*)homeTitleViewController
{
    if(!_homeTitleViewController){
        _homeTitleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyHomeTitleViewController"];
    }
    return _homeTitleViewController;
}



#pragma mark - login action

- (void)handlerAutoLogin
{
    
    NSDictionary *user = [[DBM dbm] lastLoginUser];
 
    //如果读不到之前的用户登录：：
    if (!user) {
        UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyVisitorViewController"];
        [self.navigationController pushViewController:destVC animated:NO];
        return;
    } else if (user && ![[user valueForKey:@"autologin"] boolValue]) {
        UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyVisitorViewController"];
        [self.navigationController pushViewController:destVC animated:NO];
        return;
        
    } else if (user && [[user valueForKey:@"autologin"] boolValue]) {
        //如果需要自动登录，则判断相关数据是否有效，进行自动登录：：
        if ([user valueForKey:@"phone"] && [user valueForKey:@"pwd"]) {
            
            [self sendRequest:
             
             @{@"phone":[user valueForKey:@"phone"],
             @"phoneType":GetOSName(),
             @"iemi":[OpenUDID value],
             @"pwd":[user valueForKey:@"pwd"]}
             
                       action:wlLogin
                baseUrlString:wlServer];
            return;
        }
    }
    
    
    /*
     <Users: 0x1f11d520> (entity: Users; id: 0x1f11dfb0 <x-coredata://63DBB04C-413A-4A71-81B6-CD6F60119914/Users/p1> ; data: {
     apkUrl = "http://42.121.106.113:80/bdcServer/DownLoadServlet";
     autologin = 1;
     fetchedLastLoginUser = "<relationship fault: 0x1f11d7b0 'fetchedLastLoginUser'>";
     ftpAccount = admin;
     ftpIp = "42.121.106.113";
     ftpPwd = "hdjs_2013";
     imPort = 5222;
     imServerName = ay12120201181102f7573;
     imUrl = "42.121.106.113";
     lastlogin = "2013-07-18 11:23:30 +0000";
     memberId = 109;
     phone = nil;
     pwd = e10adc3949ba59abbe56e057f20f883e;
     userName = nil;
     usertype = 0;
     version = "\U9047\U5230\U65f6\U4fee\U6539";
     })
     */
    
}

- (void)gotoLogin
{
    if (![DBM dbm].isLogined) {
        UIViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyLoginViewController"];
        [self.navigationController pushViewController:loginViewController animated:NO];
    }
    
}


#pragma mark - VC controller

- (void)pushViewController:(NSString*)identifier
{
    UIViewController * v = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    if(v){
        [self.navigationController pushViewController:v animated:YES];
    }
}

- (void)updateBadgeNumber:(NSNotification *)notification
{
    
    NSMutableDictionary *messageDataBase;
    NSString *messageDataBasePath = [[FileManage documentsPath] stringByAppendingPathComponent:@"MessageDataBase.chat"];
    NSData *messageData = [NSData dataWithContentsOfFile:messageDataBasePath];
    if (messageData != NULL) {
        messageDataBase = [NSKeyedUnarchiver unarchiveObjectWithData:messageData];
    } else {
        messageDataBase = [NSMutableDictionary dictionary];
    }
    
    NSUInteger unreadedQTJDNumber = [[[messageDataBase objectForKey:@"QTJD"] objectForKey:@"unreadedMessage"] count];
    NSUInteger unreadedJSSJNumber = [[[messageDataBase objectForKey:@"JSSJ"] objectForKey:@"unreadedMessage"] count];
    NSUInteger unreadedXTXXNumber = [[[messageDataBase objectForKey:@"XTXX"] objectForKey:@"unreadedMessage"] count];
    NSArray *numbersArray = [NSArray arrayWithObjects:
                             [NSNumber numberWithInt:unreadedQTJDNumber],
                             [NSNumber numberWithInt:unreadedJSSJNumber],
                             [NSNumber numberWithInt:unreadedXTXXNumber], nil];
    
    [_launcherViewController updateBadgeNumbers:numbersArray];
}

- (void)showViewControllerByIdentifier:(NSNotification *)notification
{
    NSString* dest = [notification.userInfo objectForKey:@"Identifier"];
    BOOL isPush = [[notification.userInfo objectForKey:@"push"] boolValue];
    if(!IsEmptyString(dest)){
        if([dest isEqualToString:@"showWlhyLoginScanView"]){
            UIViewController * v = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyEquipInfoViewController"];
            [self.navigationController pushViewController:v animated:NO];
            
        }else if (isPush){
            [self pushViewControllerWithIdentifier:dest];
            
        }else if([dest isEqualToString:@"Message"]){
            [self messageProcess:[notification.userInfo objectForKey:@"select"]];
        }else{
            [self performSegueWithIdentifier:dest sender:self];
        }
    }
}

- (void)pushViewControllerWithIdentifier:(NSString *)vcIdentifier
{
    if (![DBM dbm].isLogined) {
        [self showText:@"您好，请先登录！"];
        [self performSelector:@selector(pushViewController:) withObject:@"WlhyLoginViewController" afterDelay:1.0f];
        return;
    }
    
    if ([vcIdentifier isEqualToString:@"WlhyPrivateTrainViewController"]) {
        if ([[DBM dbm].usersExt.memberStatus intValue] != 1) {
            //账户未激活：：
            UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyNoTrainViewController"];
            if ([destVC respondsToSelector:@selector(setDesc:)]) {
                [destVC setValue:@"服务未激活，详情请咨询前台或者您的私教人员。" forKey:@"desc"];
            }
            [self.navigationController pushViewController:destVC animated:YES];
            return;
        }
    } else if ([vcIdentifier isEqualToString:@"WlhyFitnessHallViewController"]) {
        if ([[DBM dbm].usersExt.memberStatus intValue] != 1) {
            //账户未激活：：
            UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyNoTrainViewController"];
            if ([destVC respondsToSelector:@selector(setDesc:)]) {
                [destVC setValue:@"服务未激活，不能进入健身大厅。详情请咨询前台或者您的私教人员。" forKey:@"desc"];
            }
            [self.navigationController pushViewController:destVC animated:YES];
            return;
        }
    }
    
    UIViewController * v = [self.storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
    [self.navigationController pushViewController:v animated:YES];
}

-(void)messageProcess:(NSString*)message
{
    if([message isEqualToString:wlGetMemberInfoRequest]){
        
        NSLog(@"%@ , %@", [DBM dbm].currentUsers.memberId, [DBM dbm].currentUsers.pwd);
        
        [self sendRequest:
         
         @{@"memberId":[DBM dbm].currentUsers.memberId,
         @"pwd":[DBM dbm].currentUsers.pwd}
         
                   action:wlGetMemberInfoRequest
         baseUrlString:wlServer];
    }
    
    [self getPrescriptionOverviewAction];
    [self setXmppStream];
}


#pragma mark - processRequest

-(void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"info :: %@ , error :: %@", info, error);
    
    if(!error){
        NSNumber* errorCode = [info objectForKey:@"errorCode"];
        
        if(errorCode.intValue == 0){
            
            if([action isEqualToString:wlGetPrescriptionOverviewRequest]){
                
                //获取------处方概要------成功：：
                
                /*
                 {
                 errorCode = 0;
                 errorDesc = "\U67e5\U8be2\U5904\U65b9\U6982\U51b5\U6210\U529f";
                 exerciseGoals = "\U63d0\U9ad8\U5fc3\U80ba\U529f\U80fd";
                 exerciseProgram = "1\U3001\U8dd1\U6b65\U673a";
                 friendTips = "\U6309\U7167\U5904\U65b9\U63a8\U8350\U7684\U6b21\U5e8f\U8fdb\U884c\U5065\U8eab\U80fd\U5927\U5e45\U5ea6\U63d0\U9ad8\U5065\U8eab\U7684\U6548\U679c\Uff0c\U907f\U514d\U8fd0\U52a8\U4f24\U5bb3\U3002";
                 plannedGoal = 5;
                 prescriptionId = "1d2a9fda-7bc4-44bf-80c2-b6d0e79b9f6f";
                 restflag = 1;
                 tips = "\U8981\U575a\U6301\U79d1\U5b66\U6709\U89c4\U5f8b\U7684\U8fd0\U52a8\Uff0c\U5426\U5219\U52a8\U4e0d\U5982\U4e0d\U52a8\U3002";
                 }
                */
                
                DBM *dbm = [DBM dbm];
                Prescription *p = [dbm getPrescriptionByMemberId:dbm.currentUsers.memberId];
                if(!p){
                    p = [dbm createNewRecord:@"Prescription"];
                }
                [dbm saveRecord:p info:info];
                dbm.prescription = p;
                [dbm saveContext];

            }else if([wlGetMemberInfoRequest isEqualToString:action]){
                
                //获取-----会员详细信息----------成功：：
                NSLog(@"userExt :: %@", info);
                
                /*
                 {
                 affiliation = "";
                 birthday = "2013-08-13";
                 bmi = "22.9";
                 certificate = "";
                 city = "\U5317\U4eac";
                 clubid = 001003015;
                 clubname = "wangm\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
                 companyId = "";
                 errorCode = 0;
                 errorDesc = "\U83b7\U5f97\U4f1a\U5458\U6210\U529f";
                 expertId = "";
                 hdi = 0;
                 height = 175;
                 iemi = "";
                 integral = 0;
                 isModifyBaseInfo = 0;
                 isModifyWHSInfo = 0;
                 isVip = 0;
                 manifesto = "";
                 memLevel = 0;
                 memberId = 304;
                 memberStatus = 1;
                 name = "\U65b0\U5bbe";
                 phone = 12345678957;
                 phoneType = "";
                 "phone_new" = "";
                 picPath = "";
                 pwd = 96e79218965eb72c92a549dd5a330112;
                 "pwd_new" = "";
                 serviceAccount = 13466654376;
                 servicePersonId = 151;
                 serviceuserType = "";
                 sex = 1;
                 sportEquips = "1,2,3,5";
                 sportItems = "1,2,3,5";
                 sportPeriods = "1,2";
                 sportTimes = 2;
                 state = 0;
                 statusDesc = "\U670d\U52a1\U6b63\U5e38";
                 totalDistance = 0;
                 totalEnergy = 0;
                 totalTime = 0;
                 updateFlag = 000;
                 vitality = 0;
                 waist = 70;
                 weight = 70;
                 x = 0;
                 y = 0;
                 }
                */
                
                
                /*
                 @property (nonatomic, retain) NSNumber * memberId;
                 @property (nonatomic, retain) NSString * name;
                 @property (nonatomic, retain) NSString * phone;
                 @property (nonatomic, retain) NSString * phoneType;
                 @property (nonatomic, retain) NSString * phone_new;
                 @property (nonatomic, retain) NSString * pwd;
                 @property (nonatomic, retain) NSString * pwd_new;
                 
                 @property (nonatomic, retain) NSString * picPath;
                 @property (nonatomic, retain) NSNumber * sex;
                 @property (nonatomic, retain) NSString * iemi;
                 @property (nonatomic, retain) NSString * birthday;
                 @property (nonatomic, retain) NSString * bmi;
                 
                 @property (nonatomic, retain) NSNumber * height;
                 @property (nonatomic, retain) NSString * vitality;
                 @property (nonatomic, retain) NSNumber * waist;
                 @property (nonatomic, retain) NSNumber * weight;
                 @property (nonatomic, retain) NSString * integral;
                 
                 @property (nonatomic, retain) NSString * isModifyBaseInfo;
                 @property (nonatomic, retain) NSString * isVip;
                 @property (nonatomic, retain) NSString * memberStatus;
                 @property (nonatomic, retain) NSNumber * memLevel;
                 
                 @property (nonatomic, retain) NSNumber * deptId;
                 @property (nonatomic, retain) NSString * serviceAccount;
                 @property (nonatomic, retain) NSNumber * servicePersonId;
                 @property (nonatomic, retain) NSString * serviceStar;
                 
                 @property (nonatomic, retain) NSString * sportEquips;
                 @property (nonatomic, retain) NSString * sportItems;
                 @property (nonatomic, retain) NSString * sportPeriods;
                 @property (nonatomic, retain) NSString * sportTimes;
                 @property (nonatomic, retain) NSString * statusDesc;
                 @property (nonatomic, retain) NSString * totalEnergy;
                 @property (nonatomic, retain) NSString * totalTime;
                */
                
                DBM *dbm = [DBM dbm];
                
                UsersExt *userExt = [[DBM dbm] getUsersExtByMemberId:dbm.currentUsers.memberId];
                if(!userExt){
                    userExt = [dbm createNewRecord:@"UsersExt"];
                }
                
                [dbm saveRecord:userExt info:info];
                
                userExt.deptid = [info objectForKey:@"clubid"];
                dbm.usersExt = userExt;
                dbm.currentUsers.userName = userExt.name;
                [dbm saveContext];
                
                [self updateDisplay];
                
            }else if ([action isEqualToString:wlLogin]){
                //--------自动登录-------成功：：
                
                Users *obj = [[DBM dbm] getUserByMemberId:[info valueForKey:@"memberId"]];
                if(!obj){
                    obj = [[DBM dbm] createNewRecord:@"Users"];
                }
                
                [[DBM dbm] saveRecord:obj info:info];
                [obj setValue:localNow() forKey:@"lastlogin"];
                [obj setValue:[NSNumber numberWithBool: YES] forKey:@"autologin"];
                
                [DBM dbm].currentUsers = obj;
                [DBM dbm].isLogined = YES;
                [[DBM dbm] saveContext];
                
                postNotification(wlhyShowViewControllerNotification, @{@"Identifier":@"Message",
                                 @"select":wlGetMemberInfoRequest});
            }
            
            
        } else if(errorCode.intValue == 1){
            
            if([action isEqualToString:wlGetPrescriptionOverviewRequest]){
                [self.tableView reloadData];
                
            } else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
        
        }else {
            [self showText:[info objectForKey:@"errorDesc"]];
        }
    }else{
        [self showText:@"连接服务器失败！"];
    }
}



#pragma mark --- actions

-(IBAction)startNewSport:(id)sender
{
    if (![DBM dbm].isLogined) {
        [self showText:@"您好，请先登录！"];
        [self performSelector:@selector(pushViewController:) withObject:@"WlhyLoginViewController" afterDelay:1.0f];
        return;
    } else {
        //用户已登录，则获取用户详情，判断其个人信息是否完善：：
        UsersExt *usersExt = [[DBM dbm] getUsersExtByMemberId:[DBM dbm].currentUsers.memberId];
        if ([usersExt.weight floatValue] == 0 || [usersExt.height floatValue] == 0 || [usersExt.waist floatValue] == 0) {
            [self showText:@"完善个人基本信息才能开始运动"];
            [self performSelector:@selector(pushBaseInfoVC:) withObject:nil afterDelay:1.5f];
            
            return;
        }
        if ([[DBM dbm].usersExt.memberStatus intValue] != 1) {
            //账户未激活：：
            UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyNoTrainViewController"];
            if ([destVC respondsToSelector:@selector(setDesc:)]) {
                [destVC setValue:@"服务未激活，请激活服务后再使用。" forKey:@"desc"];
            }
            [self.navigationController pushViewController:destVC animated:YES];
            return;
        }
    }
    
    //一切OK的话，直接进 WlhyNewSportViewController：：
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyNewSportViewController"];
    if(destVC){
        [self.navigationController pushViewController:destVC animated:YES];
    }
    
}

- (void)pushBaseInfoVC:(id)sender
{
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyUserBaseInfoViewController"];
    if([destVC respondsToSelector:@selector(setIsForMakeUpInfo:)]){
        [destVC setValue:@YES forKey:@"isForMakeUpInfo"];
        [self.navigationController pushViewController:destVC animated:YES];
    }
}

// private functions
#pragma mark need to get 获得处方一天概况
- (BOOL)isNeedGetPrescription
{
    return ([DBM dbm].prescription == nil && [DBM dbm].isLogined);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1){
        
        CMPopTipView* tips = [[CMPopTipView alloc] initWithMessage:WlhyString(_goalLabel.text)];
        tips.dismissTapAnywhere=YES;
        [tips presentPointingAtView:_goalLabel inView:tableView animated:YES];
        
    } else if (indexPath.row == 2) {
        CMPopTipView* tips = [[CMPopTipView alloc] initWithMessage:WlhyString(_paramLabel.text)];
        tips.dismissTapAnywhere=YES;
        [tips presentPointingAtView:_paramLabel inView:tableView animated:YES];
    }
}



@end
