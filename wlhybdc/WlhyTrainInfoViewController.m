//
//  WlhyTrainInfoViewController.m
//  wlhybdc
//
//  Created by ios on 13-7-18.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyTrainInfoViewController.h"

@interface WlhyTrainInfoViewController ()

@property(strong, nonatomic) IBOutlet UIImageView *trainImageView;
@property(strong, nonatomic) IBOutlet UILabel *trainNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *trainLevelLabel;
@property(strong, nonatomic) IBOutlet UILabel *trainSexLabel;
@property(strong, nonatomic) IBOutlet UILabel *trainStatusLabel;
@property(strong, nonatomic) IBOutlet UILabel *trainQQLabel;
@property(strong, nonatomic) IBOutlet UILabel *trainWorkTimeLabel;
@property(strong, nonatomic) IBOutlet UILabel *trainTelLabel;
@property(strong, nonatomic) IBOutlet UILabel *trainIntroductionLabel;
@property(strong, nonatomic) IBOutlet UILabel *trainExperienceLabel;

@property(strong, nonatomic) IBOutlet UIButton *bindButton;

@property(strong, nonatomic) NSDictionary *trainInfo;

@end

@implementation WlhyTrainInfoViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - VC life

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"私教详情";
    
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
}


- (void)viewWillAppear:(BOOL)animated
{
    
    //页面出现的时候，根据私教id去请求私教详细信息：：
    if (!_trainInfo) {
        [self sendRequest:
         
         @{
         @"memberId":[DBM dbm].currentUsers.memberId,
         @"pwd":[DBM dbm].currentUsers.pwd,
         @"servicePersonId": _trainID
         }
         
                   action:wlGetCertainTrainInfoRequest
            baseUrlString:wlServer];
    }
    
    if (_rechargeVCPurpose == RechargeVCPurposeChangeTrain) {
        [_bindButton setTitle:@"选为我的新私教" forState:UIControlStateNormal];
    } else if (_rechargeVCPurpose == RechargeVCPurposeSportGuide) {
        [_bindButton setTitle:@"选为本次运动的指导私教" forState:UIControlStateNormal];
    } else if (_rechargeVCPurpose == RechargeVCPurposeRecharge) {
        [_bindButton setTitle:@"选为我的健身私教" forState:UIControlStateNormal];
    }
}

- (void)viewDidUnload
{
    
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
    }
    self.trainImageView = nil;
    self.trainNameLabel = nil;
    self.trainLevelLabel = nil;
    self.trainSexLabel = nil;
    self.trainStatusLabel = nil;
    self.trainQQLabel = nil;
    self.trainWorkTimeLabel = nil;
    self.trainTelLabel = nil;
    self.trainIntroductionLabel = nil;
    self.trainExperienceLabel = nil;
    self.bindButton = nil;
    
    self.trainInfo = nil;
}

#pragma mark - processRequest

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"info :: %@ , error :: %@", info, error);
    
    if(!error){
        NSNumber* errorCode = [info objectForKey:@"errorCode"];
        if(errorCode.intValue == 0){
            
            if ([action isEqualToString:wlGetCertainTrainInfoRequest]) {
                _trainInfo = info;
                [self updateTableWithTrainInfo];
                
            } else if ([action isEqualToString:wlBindTrainRequest]) {
                //绑定成功：：
                [self showText:@"私教绑定成功"];
                [self updateLocalData];
                [self performSelector:@selector(backHome:) withObject:nil afterDelay:1.5f];
            }
            
        }else {
            [self showText:[info objectForKey:@"errorDesc"]];
        }
    }else{
        [self showText:@"连接服务器失败！"];
    }
}

- (void)updateLocalData
{
    NSNumber* memberId = [DBM dbm].currentUsers.memberId;
    UsersExt *obj = [[DBM dbm] getUsersExtByMemberId:memberId];
    
    if(!obj){
        obj = [[DBM dbm] createNewRecord:@"UsersExt"];
        [[DBM dbm] saveRecord:obj info:_trainInfo];
    }
    
    [obj setValue:[_trainInfo valueForKey:@"account"] forKey:@"serviceAccount"];
    [obj setValue:[_trainInfo valueForKey:@"userName"] forKey:@"serviceName"];
    [obj setValue:_trainID forKey:@"servicePersonId"];
    [obj setValue:[NSString stringWithFormat:@"%i", 1] forKey:@"memberStatus"];
    
    //更新缓存中的usersExt：：
    [DBM dbm].usersExt = obj;
    
    [[DBM dbm] saveContext];
    
    /*
     @property (nonatomic, retain) NSNumber * deptid;
     @property (nonatomic, retain) NSString * deptName;
     @property (nonatomic, retain) NSString * serviceAccount;
     @property (nonatomic, retain) NSNumber * servicePersonId;
     @property (nonatomic, retain) NSString * serviceStar;
     */
    
    
    
    
    /*
     @property (nonatomic, retain) NSString * birthday;
     @property (nonatomic, retain) NSString * bmi;
     @property (nonatomic, retain) NSNumber * deptid;
     @property (nonatomic, retain) NSNumber * height;
     @property (nonatomic, retain) NSString * iemi;
     @property (nonatomic, retain) NSString * integral;
     @property (nonatomic, retain) NSString * isModifyBaseInfo;
     @property (nonatomic, retain) NSString * isVip;
     @property (nonatomic, retain) NSNumber * memberId;
     @property (nonatomic, retain) NSString * memberStatus;
     @property (nonatomic, retain) NSNumber * memLevel;
     @property (nonatomic, retain) NSString * name;
     @property (nonatomic, retain) NSString * phone;
     @property (nonatomic, retain) NSString * phone_new;
     @property (nonatomic, retain) NSString * phoneType;
     @property (nonatomic, retain) NSString * picPath;
     @property (nonatomic, retain) NSString * pwd;
     @property (nonatomic, retain) NSString * pwd_new;
     @property (nonatomic, retain) NSString * deptName;
     @property (nonatomic, retain) NSString * serviceAccount;
     @property (nonatomic, retain) NSNumber * servicePersonId;
     @property (nonatomic, retain) NSString * serviceStar;
     @property (nonatomic, retain) NSNumber * sex;
     @property (nonatomic, retain) NSString * sportEquips;
     @property (nonatomic, retain) NSString * sportItems;
     @property (nonatomic, retain) NSString * sportPeriods;
     @property (nonatomic, retain) NSString * sportTimes;
     @property (nonatomic, retain) NSString * statusDesc;
     @property (nonatomic, retain) NSString * totalEnergy;
     @property (nonatomic, retain) NSString * totalTime;
     @property (nonatomic, retain) NSString * vitality;
     @property (nonatomic, retain) NSNumber * waist;
     @property (nonatomic, retain) NSNumber * weight;
     @property (nonatomic, retain) NSString * isModifyWHSInfo;
     @property (nonatomic, retain) NSString * serviceuserType;
     @property (nonatomic, retain) NSNumber * state;
     @property (nonatomic, retain) NSString * totalDistance;
     @property (nonatomic, retain) NSString * city;
     @property (nonatomic, retain) NSNumber * x;
     @property (nonatomic, retain) NSNumber * y;
     @property (nonatomic, retain) NSString * companyId;
     
     */
}

- (void)updateTableWithTrainInfo
{
    /*
     {
     account = 33500000000;
     activity = 0;
     age = 25;
     blog = 33500000000;
     channel = 33500000000;
     deptName = "wangm\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
     deptid = 001003015;
     eMail = 33500000000;
     educational = 4;
     errorCode = 0;
     errorDesc = "\U67e5\U8be2\U5065\U8eab\U79c1\U6559\U8be6\U7ec6\U4fe1\U606f\U6210\U529f";
     experience = "\U79c1\U65590815";
     honor = "\U79c1\U65590815";
     integral = 0;
     introduction = "\U79c1\U65590815";
     isonline = "\U79bb\U7ebf";
     level = 2;
     nickname = "\U79c1\U65590815";
     picture = "http://www.holddo.com:80/bdcServer/img/personaltrainer/33500000000.jpg";
     remark = "\U79c1\U65590815";
     sex = 2;
     specialSkill = 4;
     userName = "\U79c1\U65590815";
     userQQ = 33500000000;
     userStaticTel = "";
     userTel = 33500000000;
     userType = 41;
     worktime = "8:30-17:30";
     }
    */
    
    /*
     @property(strong, nonatomic) IBOutlet UIImageView *trainImageView;
     @property(strong, nonatomic) IBOutlet UILabel *trainNameLabel;
     @property(strong, nonatomic) IBOutlet UILabel *trainLevelLabel;
     @property(strong, nonatomic) IBOutlet UILabel *trainSexLabel;
     @property(strong, nonatomic) IBOutlet UILabel *trainStatusLabel;
     @property(strong, nonatomic) IBOutlet UILabel *trainQQLabel;
     @property(strong, nonatomic) IBOutlet UILabel *trainWorkTimeLabel;
     @property(strong, nonatomic) IBOutlet UILabel *trainEmailLabel;
     @property(strong, nonatomic) IBOutlet UILabel *trainTelLabel;
     @property(strong, nonatomic) IBOutlet UILabel *trainPhoneLabel;
     @property(strong, nonatomic) IBOutlet UILabel *trainIntroductionLabel;
     @property(strong, nonatomic) IBOutlet UILabel *trainExperienceLabel;
    */
    
    [_trainImageView setImageWithURL:[NSURL URLWithString:[_trainInfo objectForKey:@"picture"]]];
    _trainNameLabel.text = [_trainInfo objectForKey:@"userName"];
    _trainSexLabel.text = ([[_trainInfo objectForKey:@"sex"] integerValue] == 1) ? @"男" : @"女";
    _trainLevelLabel.text = [_trainInfo objectForKey:@"level"];
    _trainWorkTimeLabel.text = [_trainInfo objectForKey:@"worktime"];
    _trainQQLabel.text = @"（选为私教后可见）";      //[_trainInfo objectForKey:@"userQQ"];
    _trainTelLabel.text = @"（选为私教后可见）";     //[_trainInfo objectForKey:@"userStaticTel"];
    _trainIntroductionLabel.text = [_trainInfo objectForKey:@"introduction"];
    _trainExperienceLabel.text = [_trainInfo objectForKey:@"experience"];
    
    _trainStatusLabel.text = [_trainInfo objectForKey:@"isonline"];
    if ([_trainStatusLabel.text isEqualToString:@"离线"]) {
        _trainStatusLabel.textColor = [UIColor colorWithRed:0.9 green:0.4 blue:0.4 alpha:1.0];
    }
}

#pragma mark - IBAction  


- (IBAction)bindTrain:(id)sender
{
    
    NSLog(@"bind train info :: %@", _trainInfo);
    
    if (_rechargeVCPurpose == RechargeVCPurposeChangeTrain) {
        
        NSDictionary *changeDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [_trainInfo objectForKey:@"userName"],  @"trainName",
                                   _trainID,  @"trainId",
                                   [_trainInfo objectForKey:@"account"], @"account",
                                   nil];
        
        UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyChangeTrainViewController"];
        if(destVC && [destVC respondsToSelector:@selector(setChangeDic:)]){
            [destVC setValue:changeDic forKey:@"changeDic"];
            [self.navigationController pushViewController:destVC animated:YES];
        }
    } else if (_rechargeVCPurpose == RechargeVCPurposeRecharge) {
        
        /*
         memberId
         pwd
         servicePersonId
        */
        
        [self sendRequest:
         
         @{@"memberId":[DBM dbm].currentUsers.memberId,
         @"pwd":[DBM dbm].currentUsers.pwd,
         @"servicePersonId": _trainID}
         
                   action:wlBindTrainRequest
            baseUrlString:wlServer];
    } else if (_rechargeVCPurpose == RechargeVCPurposeSportGuide) {
        //临时指导：：
        if ([_trainStatusLabel.text isEqualToString:@"离线"]) {
            [self showText:@"该私教当前不在线"];
            return;
        }
        
        UIViewController *destVC = [self.navigationController.viewControllers objectAtIndex:2];
        if ([destVC respondsToSelector:@selector(setTemporaryTrainID:)]) {
            [destVC setValue:_trainID forKey:@"temporaryTrainID"];
        }
        if ([destVC respondsToSelector:@selector(setIsBackFromTrainSelection:)]) {
            [destVC setValue:@YES forKey:@"isBackFromTrainSelection"];
        }
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2]animated:NO];
        
    }
    
    /*
     {
     account = 13466654376;
     deptName = "wangm\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
     deptid = 001003015;
     eMail = "hdjs@huidong.com";
     errorCode = 0;
     errorDesc = "\U67e5\U8be2\U5065\U8eab\U79c1\U6559\U8be6\U7ec6\U4fe1\U606f\U6210\U529f";
     isonline = "\U79bb\U7ebf";
     picture = "http://www.holddo.com:80/bdcServer/img/personaltrainer/13466654376.jpg";
     remark = "\U70ed\U7231\U79c1\U6559\U5de5\U4f5c~";
     sex = 2;
     specialSkill = 4;
     userName = "\U738b\U840c";
     userQQ = 13466654373;
     userStaticTel = "";
     userTel = 13466654376;
     userType = 41;
     worktime = "";
     }
     
     */
    
}

- (void)backHome:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
